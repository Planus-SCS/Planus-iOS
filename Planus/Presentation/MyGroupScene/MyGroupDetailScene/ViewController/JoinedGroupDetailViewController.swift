//
//  JoinedGroupDetailViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit
import RxSwift
import SnapKit

class JoinedGroupDetailViewController: UIViewController {
    var bag = DisposeBag()
    var viewModel: JoinedGroupDetailViewModel?
    
    var titleFetched = BehaviorSubject<String?>(value: nil)
    var needRefresh = PublishSubject<Void>()
    
    var headerView = JoinedGroupDetailHeaderView(frame: .zero)
    var headerTabView = JoinedGroupDetailHeaderTabView(frame: .zero)
    var bottomView = UIView(frame: .zero)
    var headerViewHeightConstraint: NSLayoutConstraint?
    
    lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        return pageViewController
    }()
    
    var childList = [UIViewController]()
    
    var noticeViewController: JoinedGroupNoticeViewController?
    var calendarViewController: JoinedGroupCalendarViewController?
    var chatViewController: JoinedGroupChattingViewController?

    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
        
    convenience init(viewModel: JoinedGroupDetailViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configureView()
        configureLayout()
        configureChild()
        configurePanGesture()
        
        bind()
        navigationItem.setLeftBarButton(backButton, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleFetched
            .withUnretained(self)
            .compactMap { $0 }
            .subscribe(onNext: { vc, title in
                vc.navigationItem.title = title
            })
            .disposed(by: bag)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = JoinedGroupDetailViewModel.Input(
            viewDidLoad: Observable.just(()),
            onlineStateChanged: headerView.onlineSwitch.rx.isOn.asObservable(),
            refreshRequested: needRefresh.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output
            .didFetchGroupDetail
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.titleFetched.onNext(viewModel.groupTitle)
                vc.headerView.tagLabel.text = viewModel.tag?.map { "#\($0)" }.joined(separator: " ")
                vc.headerView.memberCountButton.setTitle("\(viewModel.memberCount ?? 0)/\(viewModel.limitCount ?? 0)", for: .normal)
                vc.headerView.captinButton.setTitle(viewModel.leaderName, for: .normal)
                vc.setMenuButton(isLeader: viewModel.isLeader)
                if let url = viewModel.groupImageUrl {
                    viewModel.fetchImage(key: url)
                        .observe(on: MainScheduler.asyncInstance)
                        .subscribe(onSuccess: { data in
                            vc.headerView.titleImageView.image = UIImage(data: data)
                        })
                        .disposed(by: vc.bag)
                }
                switch message {
                case .update:
                    vc.showToast(message: "그룹 정보를 수정하였습니다.", type: .normal)
                case .refresh:
                    vc.showToast(message: "새로고침을 완료하였습니다.", type: .normal)
                default:
                    return
                }
            })
            .disposed(by: bag)
        
        output
            .isOnline
            .compactMap { $0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: headerView.onlineSwitch.rx.isOn)
            .disposed(by: bag)
        
        output
            .onlineCountChanged
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, count in
                vc.headerView.onlineButton.setTitle("\(count)", for: .normal)
            })
            .disposed(by: bag)

        output
            .noticeFetched
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, notice in
                vc.noticeViewController?.viewModel?.notice.onNext(notice)
            })
            .disposed(by: bag)
        
        output
            .showMessage
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                print(message)
                vc.showToast(message: message, type: .normal)
            })
            .disposed(by: bag)
        
    }
    
    func setMenuButton(isLeader: Bool?) {
        let image = UIImage(named: "dotBtn")
        var item: UIBarButtonItem
        var menuChild = [UIAction]()
        let link = UIAction(title: "공유하기", handler: { _ in print("전체 캘린더 조회") })
        menuChild.append(link)
        if isLeader ?? false {
            let editInfo = UIAction(title: "그룹 정보 수정", handler: { [weak self] _ in
                self?.editInfo()
            })
            let editNotice = UIAction(title: "공지사항 수정", handler: { [weak self] _ in
                self?.editNotice()
            })
            let editMember = UIAction(title: "멤버 수정", handler: { [weak self] _ in
                self?.editMember()
            })
            
            menuChild.append(editInfo)
            menuChild.append(editNotice)
            menuChild.append(editMember)
        }
        
        let menu = UIMenu(options: .displayInline, children: menuChild)
        item = UIBarButtonItem(image: image, menu: menu)
        item.tintColor = UIColor(hex: 0x000000)
        navigationItem.setRightBarButton(item, animated: true)
    }
    
    lazy var editNotice: () -> Void = { [weak self] () -> Void in
        guard let groupId = self?.viewModel?.groupId,
              let notice = try? self?.viewModel?.groupNotice.value()  else { return }
        
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let updateNoticeUseCase = DefaultUpdateNoticeUseCase.shared
    
        let vm = MyGroupNoticeEditViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            updateNoticeUseCase: updateNoticeUseCase
        )
        vm.setNotice(groupId: groupId, notice: notice)
        let vc = MyGroupNoticeEditViewController(viewModel: vm)
        self?.navigationController?.pushViewController(vc, animated: true)
    }
    
    lazy var editMember: () -> Void = { [weak self] in
        guard let groupId = self?.viewModel?.groupId else { return }
        
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
        let imageRepo = DefaultImageRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let fetchMyGroupMemberListUseCase = DefaultFetchMyGroupMemberListUseCase(myGroupRepository: myGroupRepo)
        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
        
        let vm = MyGroupMemberEditViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            fetchMyGroupMemberListUseCase: fetchMyGroupMemberListUseCase,
            fetchImageUseCase: fetchImageUseCase,
            memberKickOutUseCase: DefaultMemberKickOutUseCase.shared
        )
        vm.setGroupId(id: groupId)
        let vc = MyGroupMemberEditViewController(viewModel: vm)
        self?.navigationController?.pushViewController(vc, animated: true)
    }
    
    lazy var editInfo: () -> Void = { [weak self] in
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
        let imageRepo = DefaultImageRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let updateGroupInfoUseCase = DefaultUpdateGroupInfoUseCase.shared
        let vm = MyGroupInfoEditViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            fetchImageUseCase: DefaultFetchImageUseCase(imageRepository: imageRepo),
            updateGroupInfoUseCase: updateGroupInfoUseCase
        )
        guard let id = self?.viewModel?.groupId,
              let title = self?.viewModel?.groupTitle,
              let url = self?.viewModel?.groupImageUrl,
              let tagList = self?.viewModel?.tag,
              let max = self?.viewModel?.limitCount else { return }
        vm.setGroup(id: id, title: title, imageUrl: url, tagList: tagList, maxMember: max)
        
        let vc = MyGroupInfoEditViewController(viewModel: vm)
        self?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func backBtnAction() {
        viewModel?.actions?.pop?()
    }
    
    var dragInitialY: CGFloat = 0
    var dragPreviousY: CGFloat = 0
    var dragDirection: DragDirection = .Up
    
    @objc func topViewMoved(_ gesture: UIPanGestureRecognizer) {
        
        var dragYDiff : CGFloat

        switch gesture.state {
            
        case .began:
            
            dragInitialY = gesture.location(in: self.view).y
            dragPreviousY = dragInitialY
            
        case .changed:
            
            let dragCurrentY = gesture.location(in: self.view).y
            dragYDiff = dragPreviousY - dragCurrentY
            dragPreviousY = dragCurrentY
            dragDirection = dragYDiff < 0 ? .Down : .Up
            innerTableViewDidScroll(withDistance: dragYDiff)
            
        case .ended:
            innerTableViewScrollEnded(withScrollDirection: dragDirection)
            
        default: return
        
        }
    }
    
    func configureView() {
        self.view.backgroundColor = .white

        self.view.addSubview(headerView)
        self.view.addSubview(bottomView)
        self.view.addSubview(headerTabView)
    }
    
    func configurePanGesture() {
        let topViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))

        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(topViewPanGesture)
    }
    
    func configureChild() {
        guard let groupId = viewModel?.groupId else { return }
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
        let imageRepo = DefaultImageRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let fetchMyGroupMemberListUseCase = DefaultFetchMyGroupMemberListUseCase(myGroupRepository: myGroupRepo)
        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
        let noticeViewModel = JoinedGroupNoticeViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            fetchMyGroupMemberListUseCase: fetchMyGroupMemberListUseCase,
            fetchImageUseCase: fetchImageUseCase,
            memberKickOutUseCase: DefaultMemberKickOutUseCase.shared
        )
        noticeViewModel.setGroupId(id: groupId)
        let noticeViewController = JoinedGroupNoticeViewController(viewModel: noticeViewModel)
        noticeViewController.delegate = self
        noticeViewController.scrollDelegate = self
        self.noticeViewController = noticeViewController
        
        let createMonthlyCalendarUseCase = DefaultCreateSocialMonthlyCalendarUseCase()
        let fetchTodoListUseCase = DefaultFetchMyGroupCalendarUseCase(myGroupRepository: myGroupRepo)
        let calendarViewModel = JoinedGroupCalendarViewModel(
            getTokenUseCase: getTokenUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            createSocialMonthlyCalendarUseCase: createMonthlyCalendarUseCase,
            fetchMyGroupCalendarUseCase: fetchTodoListUseCase
        )
        calendarViewModel.setGroupId(id: groupId)
        let calendarViewController = JoinedGroupCalendarViewController(viewModel: calendarViewModel)
        calendarViewController.delegate = self
        calendarViewController.scrollDelegate = self
        self.calendarViewController = calendarViewController
        
        let chattingViewController = JoinedGroupChattingViewController(nibName: nil, bundle: nil)
        chattingViewController.scrollDelegate = self
        self.chatViewController = chattingViewController
        
        childList.append(noticeViewController)
        childList.append(calendarViewController)
        childList.append(chattingViewController)
        
        pageViewController.setViewControllers([childList[0]], direction: .forward, animated: true)

        self.addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        bottomView.addSubview(pageViewController.view)
        
        pageViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureLayout() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(220 + UIApplication.shared.statusBarFrame.size.height + 44)
        }
        
        headerTabView.snp.makeConstraints {
            $0.bottom.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        bottomView.snp.makeConstraints {
            $0.top.equalTo(headerTabView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        guard let headerViewHeightConstraint = headerView.constraints.first(where: { $0.firstAttribute == .height }) else { return }
        self.headerViewHeightConstraint = headerViewHeightConstraint
    }
}

extension JoinedGroupDetailViewController: JoinedGroupNoticeViewControllerDelegate {
    func refreshRequested(_ viewController: JoinedGroupNoticeViewController) {
        self.needRefresh.onNext(())
    }
}


extension JoinedGroupDetailViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewControllerIndex = childList.firstIndex(where: { $0 == viewController }) {
            if (1..<childList.count).contains(currentViewControllerIndex) {
                return childList[currentViewControllerIndex - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewControllerIndex = childList.firstIndex(where: { $0 == viewController }) {
            if (0..<(childList.count - 1)).contains(currentViewControllerIndex) {
                return childList[currentViewControllerIndex + 1]
            }
        }
        return nil
    }
}

//MARK:- Delegate Method to tell Inner View Controller movement inside Page View Controller
//Capture it and change the selection bar position in collection View

extension JoinedGroupDetailViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        
        guard let currentVCIndex = childList.firstIndex(where: { $0 == currentVC }) else { return }
        
        let indexPathAtCollectionView = IndexPath(item: currentVCIndex, section: 0)
        print("fetched in firstTab")
        headerTabView.scrollToTab(index: currentVCIndex)
        switch currentVCIndex {
        case 0:
            noticeViewController?.noticeCollectionView.isHidden = true
            noticeViewController?.spinner.hidesWhenStopped = true
            noticeViewController?.spinner.startAnimating()
            self.needRefresh.onNext(())
        case 1:
            return
        case 2:
            return
        default:
            return
        }
    }
}

extension JoinedGroupDetailViewController: NestedScrollableViewScrollDelegate {
    
    var currentHeaderHeight: CGFloat? {
        return headerViewHeightConstraint?.constant
    }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        guard let headerViewHeightConstraint else { return }
        headerViewHeightConstraint.constant -= scrollDistance
        headerView.alpha = (headerViewHeightConstraint.constant - joinedGroupTopViewFinalHeight) / (joinedGroupTopViewInitialHeight - joinedGroupTopViewFinalHeight)
        if headerViewHeightConstraint.constant < joinedGroupTopViewFinalHeight {
            headerViewHeightConstraint.constant = joinedGroupTopViewFinalHeight
        } else if headerViewHeightConstraint.constant >= joinedGroupTopViewInitialHeight {
            headerViewHeightConstraint.constant = joinedGroupTopViewInitialHeight
        }
        
        
    }
//
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection) {
        guard let headerViewHeightConstraint else { return }

        let topViewHeight = headerViewHeightConstraint.constant

        /*
         *  Scroll is not restricted.
         *  So this check might cause the view to get stuck in the header height is greater than initial height.

        if topViewHeight >= topViewInitialHeight || topViewHeight <= topViewFinalHeight { return }

        */

        if topViewHeight >= joinedGroupTopViewInitialHeight {
            scrollToInitialView()
        }

    }

    func scrollToInitialView() {
        guard let headerViewHeightConstraint else { return }

        let topViewCurrentHeight = headerView.frame.height

        let distanceToBeMoved = abs(topViewCurrentHeight - joinedGroupTopViewInitialHeight)

        var time = distanceToBeMoved / 500

        if time < 0.2 {

            time = 0.2
        }

        headerViewHeightConstraint.constant = joinedGroupTopViewInitialHeight

//        UIView.animate(withDuration: TimeInterval(time), animations: {
//
//            self.view.layoutIfNeeded()
//        })
    }

    func scrollToFinalView() {
        guard let headerViewHeightConstraint else { return }

        let topViewCurrentHeight = headerView.frame.height

        let distanceToBeMoved = abs(topViewCurrentHeight - joinedGroupTopViewFinalHeight)

        var time = distanceToBeMoved / 500

        if time < 0.2 {

            time = 0.2
        }

        headerViewHeightConstraint.constant = joinedGroupTopViewFinalHeight

//        UIView.animate(withDuration: TimeInterval(time), animations: {
//
//            self.view.layoutIfNeeded()
//        })
    }
}

extension JoinedGroupDetailViewController: JoinedGroupCalendarViewControllerDelegate {
    func isLeader() -> Bool? {
        return viewModel?.isLeader
    }
}

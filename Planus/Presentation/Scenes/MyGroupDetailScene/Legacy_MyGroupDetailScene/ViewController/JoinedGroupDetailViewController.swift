////
////  JoinedGroupDetailViewController.swift
////  Planus
////
////  Created by Sangmin Lee on 2023/04/04.
////
//
//import UIKit
//import RxSwift
//import SnapKit
//
//class JoinedGroupDetailViewController: UIViewController {
//    var bag = DisposeBag()
//    var viewModel: JoinedGroupDetailViewModel?
//    
//    var currentIndex = BehaviorSubject<Int?>(value: nil)
//    
//    var titleFetched = BehaviorSubject<String?>(value: nil)
//    var needRefresh = PublishSubject<Void>()
//    
//    var headerView = JoinedGroupDetailHeaderView(frame: .zero)
//    var headerTabView = JoinedGroupDetailHeaderTabView(frame: .zero)
//    var bottomView = UIView(frame: .zero)
//    var headerViewHeightConstraint: NSLayoutConstraint?
//    
//    lazy var pageViewController: UIPageViewController = {
//        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
//        pageViewController.dataSource = self
//        pageViewController.delegate = self
//        pageViewController.view.backgroundColor = UIColor(hex: 0xF5F5FB)
//        return pageViewController
//    }()
//    
//    var childList = [UIViewController]()
//    
//    var noticeViewController: JoinedGroupNoticeViewController?
//    var calendarViewController: JoinedGroupCalendarViewController?
//    var chatViewController: JoinedGroupChattingViewController?
//
//    lazy var backButton: UIBarButtonItem = {
//        let image = UIImage(named: "back")
//        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
//        item.tintColor = .black
//        return item
//    }()
//        
//    convenience init(viewModel: JoinedGroupDetailViewModel) {
//        self.init(nibName: nil, bundle: nil)
//        self.viewModel = viewModel
//    }
//    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = .white
//        configureView()
//        configureLayout()
//        configureChild()
//        configurePanGesture()
//        
//        bind()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        navigationItem.setLeftBarButton(backButton, animated: false)
//        navigationController?.interactivePopGestureRecognizer?.delegate = self
//        
//        titleFetched
//            .withUnretained(self)
//            .compactMap { $0 }
//            .subscribe(onNext: { vc, title in
//                vc.navigationItem.title = title
//            })
//            .disposed(by: bag)
//
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//    
//    func bind() {
//        guard let viewModel else { return }
//        
//        currentIndex
//            .observe(on: MainScheduler.asyncInstance)
//            .compactMap { $0 }
//            .skip(1)
//            .withUnretained(self)
//            .subscribe(onNext: { vc, index in
//                vc.headerTabView.scrollToTab(index: index)
//                switch index {
//                case 0:
//                    vc.noticeViewController?.noticeCollectionView.isHidden = true
//                    vc.noticeViewController?.spinner.hidesWhenStopped = true
//                    vc.noticeViewController?.spinner.startAnimating()
//                    vc.needRefresh.onNext(())
//                case 1:
//                    return
//                case 2:
//                    return
//                default:
//                    return
//                }
//            })
//            .disposed(by: bag)
//        
//        let input = JoinedGroupDetailViewModel.Input(
//            viewDidLoad: Observable.just(()),
//            onlineStateChanged: headerView.onlineSwitch.rx.isOn.asObservable(),
//            refreshRequested: needRefresh.asObservable()
//        )
//        let output = viewModel.transform(input: input)
//        
//        output
//            .didFetchGroupDetail
//            .compactMap { $0 }
//            .observe(on: MainScheduler.asyncInstance)
//            .withUnretained(self)
//            .subscribe(onNext: { vc, message in
//                vc.titleFetched.onNext(viewModel.groupTitle)
//                vc.headerView.tagLabel.text = viewModel.tag?.map { "#\($0)" }.joined(separator: " ")
//                vc.headerView.memberCountButton.setTitle("\(viewModel.memberCount ?? 0)/\(viewModel.limitCount ?? 0)", for: .normal)
//                vc.headerView.captinButton.setTitle(viewModel.leaderName, for: .normal)
//                vc.setMenuButton(isLeader: viewModel.isLeader)
//                if let url = viewModel.groupImageUrl {
//                    viewModel.fetchImage(key: url)
//                        .observe(on: MainScheduler.asyncInstance)
//                        .subscribe(onSuccess: { data in
//                            vc.headerView.titleImageView.image = UIImage(data: data)
//                        })
//                        .disposed(by: vc.bag)
//                }
//                switch message {
//                case .update:
//                    vc.showToast(message: "그룹 정보를 수정하였습니다.", type: .normal)
//                case .refresh:
//                    vc.showToast(message: "새로고침을 완료하였습니다.", type: .normal)
//                default:
//                    return
//                }
//            })
//            .disposed(by: bag)
//        
//        output
//            .isOnline
//            .compactMap { $0 }
//            .distinctUntilChanged()
//            .observe(on: MainScheduler.asyncInstance)
//            .bind(to: headerView.onlineSwitch.rx.isOn)
//            .disposed(by: bag)
//        
//        output
//            .onlineCountChanged
//            .compactMap { $0 }
//            .observe(on: MainScheduler.asyncInstance)
//            .withUnretained(self)
//            .subscribe(onNext: { vc, count in
//                vc.headerView.onlineButton.setTitle("\(count)", for: .normal)
//            })
//            .disposed(by: bag)
//
//        output
//            .noticeFetched
//            .compactMap { $0 }
//            .observe(on: MainScheduler.asyncInstance)
//            .withUnretained(self)
//            .subscribe(onNext: { vc, notice in
//                vc.noticeViewController?.viewModel?.notice.onNext(notice)
//            })
//            .disposed(by: bag)
//        
//        output
//            .showMessage
//            .compactMap { $0 }
//            .observe(on: MainScheduler.asyncInstance)
//            .withUnretained(self)
//            .subscribe(onNext: { vc, message in
//                vc.showToast(message: message, type: .normal)
//            })
//            .disposed(by: bag)
//        
//    }
//    
//    func setMenuButton(isLeader: Bool?) {
//        let image = UIImage(named: "dotBtn")
//        var item: UIBarButtonItem
//        var menuChild = [UIAction]()
//
//        if isLeader ?? false {
//            let editInfo = UIAction(title: "그룹 정보 수정", image: UIImage(systemName: "pencil"), handler: { [weak self] _ in
//                self?.editInfo()
//            })
//            
//            let editNotice = UIAction(title: "공지사항 수정", image: UIImage(systemName: "speaker.badge.exclamationmark.fill"), handler: { [weak self] _ in
//                self?.editNotice()
//            })
//            let editMember = UIAction(title: "멤버 수정", image: UIImage(systemName: "person"), handler: { [weak self] _ in
//                self?.editMember()
//            })
//            
//            menuChild.append(editInfo)
//            menuChild.append(editNotice)
//            menuChild.append(editMember)
//        } else {
//            let withdraw = UIAction(title: "그룹 탈퇴하기", image: UIImage(systemName: "rectangle.portrait.and.arrow.forward"), attributes: .destructive, handler: { [weak self] _ in
//                self?.withdrawGroup()
//            })
//            
//            menuChild.append(withdraw)
//        }
//        
//        let menu = UIMenu(options: .displayInline, children: menuChild)
//        item = UIBarButtonItem(image: image, menu: menu)
//        item.tintColor = UIColor(hex: 0x000000)
//        navigationItem.setRightBarButton(item, animated: true)
//    }
//    
//    func withdrawGroup() {
//        self.showPopUp(title: "그룹 탈퇴하기", message: "정말로 그룹을 탈퇴하시겠습니까?", alertAttrs: [
//            CustomAlertAttr(title: "취소", actionHandler: {}, type: .normal),
//            CustomAlertAttr(title: "탈퇴", actionHandler: { [weak self] in self?.viewModel?.withdrawGroup()}, type: .warning)]
//        )
//    }
//    
//    lazy var editNotice: () -> Void = { [weak self] () -> Void in
//        guard let groupId = self?.viewModel?.groupId,
//              let notice = try? self?.viewModel?.groupNotice.value()  else { return }
//        
//        let api = NetworkManager()
//        let keyChain = KeyChainManager()
//        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyValueStorage: keyChain)
//        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
//        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
//        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
//        let updateNoticeUseCase = DefaultUpdateNoticeUseCase.shared
//    
//        let vm = MyGroupNoticeEditViewModel(
//            getTokenUseCase: getTokenUseCase,
//            refreshTokenUseCase: refreshTokenUseCase,
//            updateNoticeUseCase: updateNoticeUseCase
//        )
//        vm.setNotice(groupId: groupId, notice: notice)
//        let vc = MyGroupNoticeEditViewController(viewModel: vm)
//        self?.navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    lazy var editMember: () -> Void = { [weak self] in
//        guard let groupId = self?.viewModel?.groupId else { return }
//        
//        let api = NetworkManager()
//        let keyChain = KeyChainManager()
//        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyValueStorage: keyChain)
//        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
//        let imageRepo = DefaultImageRepository(apiProvider: api)
//        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
//        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
//        let fetchMyGroupMemberListUseCase = DefaultFetchMyGroupMemberListUseCase(myGroupRepository: myGroupRepo)
//        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
//        
//        let vm = MyGroupMemberEditViewModel(
//            getTokenUseCase: getTokenUseCase,
//            refreshTokenUseCase: refreshTokenUseCase,
//            fetchMyGroupMemberListUseCase: fetchMyGroupMemberListUseCase,
//            fetchImageUseCase: fetchImageUseCase,
//            memberKickOutUseCase: DefaultMemberKickOutUseCase.shared
//        )
//        vm.setGroupId(id: groupId)
//        let vc = MyGroupMemberEditViewController(viewModel: vm)
//        self?.navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    lazy var editInfo: () -> Void = { [weak self] in
//        let api = NetworkManager()
//        let keyChain = KeyChainManager()
//        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyValueStorage: keyChain)
//        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
//        let imageRepo = DefaultImageRepository(apiProvider: api)
//        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
//        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
//        let updateGroupInfoUseCase = DefaultUpdateGroupInfoUseCase.shared
//        let vm = MyGroupInfoEditViewModel(
//            getTokenUseCase: getTokenUseCase,
//            refreshTokenUseCase: refreshTokenUseCase,
//            fetchImageUseCase: DefaultFetchImageUseCase(imageRepository: imageRepo),
//            updateGroupInfoUseCase: updateGroupInfoUseCase,
//            deleteGroupUseCase: DefaultDeleteGroupUseCase.shared
//        )
//        guard let id = self?.viewModel?.groupId,
//              let title = self?.viewModel?.groupTitle,
//              let url = self?.viewModel?.groupImageUrl,
//              let tagList = self?.viewModel?.tag,
//              let max = self?.viewModel?.limitCount else { return }
//        vm.setGroup(id: id, title: title, imageUrl: url, tagList: tagList, maxMember: max)
//        
//        let vc = MyGroupInfoEditViewController(viewModel: vm)
//        self?.navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    @objc func backBtnAction() {
//        viewModel?.actions?.pop?()
//    }
//    
//    var dragInitialY: CGFloat = 0
//    var dragPreviousY: CGFloat = 0
//    var dragDirection: DragDirection = .Up
//    
//    @objc func topViewMoved(_ gesture: UIPanGestureRecognizer) {
//        
//        var dragYDiff : CGFloat
//
//        switch gesture.state {
//            
//        case .began:
//            
//            dragInitialY = gesture.location(in: self.view).y
//            dragPreviousY = dragInitialY
//            
//        case .changed:
//            
//            let dragCurrentY = gesture.location(in: self.view).y
//            dragYDiff = dragPreviousY - dragCurrentY
//            dragPreviousY = dragCurrentY
//            dragDirection = dragYDiff < 0 ? .Down : .Up
//            innerTableViewDidScroll(withDistance: dragYDiff)
//            
//        case .ended:
//            innerTableViewScrollEnded(withScrollDirection: dragDirection)
//            
//        default: return
//        
//        }
//    }
//    
//    func configureView() {
//        self.view.backgroundColor = .white
//
//        self.view.addSubview(headerView)
//        self.view.addSubview(bottomView)
//        self.view.addSubview(headerTabView)
//        
//        headerTabView.delegate = self
//    }
//    
//    func configurePanGesture() {
//        let topViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))
//
//        headerView.isUserInteractionEnabled = true
//        headerView.addGestureRecognizer(topViewPanGesture)
//    }
//    
//    func configureChild() {
//        guard let groupId = viewModel?.groupId else { return }
//        let api = NetworkManager()
//        let keyChain = KeyChainManager()
//        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyValueStorage: keyChain)
//        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
//        let groupCalendarRepo = DefaultGroupCalendarRepository(apiProvider: api)
//        let imageRepo = DefaultImageRepository(apiProvider: api)
//        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
//        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
//        let fetchMyGroupMemberListUseCase = DefaultFetchMyGroupMemberListUseCase(myGroupRepository: myGroupRepo)
//        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
//        let noticeViewModel = JoinedGroupNoticeViewModel(
//            getTokenUseCase: getTokenUseCase,
//            refreshTokenUseCase: refreshTokenUseCase,
//            fetchMyGroupMemberListUseCase: fetchMyGroupMemberListUseCase,
//            fetchImageUseCase: fetchImageUseCase,
//            memberKickOutUseCase: DefaultMemberKickOutUseCase.shared,
//            setOnlineUseCase: DefaultSetOnlineUseCase.shared
//        )
//        noticeViewModel.setGroupId(id: groupId)
//        let noticeViewController = JoinedGroupNoticeViewController(viewModel: noticeViewModel)
//        noticeViewController.delegate = self
//        noticeViewController.scrollDelegate = self
//        self.noticeViewController = noticeViewController
//        
//        let createMonthlyCalendarUseCase = DefaultCreateMonthlyCalendarUseCase()
//        let fetchTodoListUseCase = DefaultFetchGroupMonthlyCalendarUseCase(groupCalendarRepository: groupCalendarRepo)
//        let calendarViewModel = JoinedGroupCalendarViewModel(
//            getTokenUseCase: getTokenUseCase,
//            refreshTokenUseCase: refreshTokenUseCase,
//            createMonthlyCalendarUseCase: createMonthlyCalendarUseCase,
//            fetchMyGroupCalendarUseCase: fetchTodoListUseCase,
//            createGroupTodoUseCase: DefaultCreateGroupTodoUseCase.shared,
//            updateGroupTodoUseCase: DefaultUpdateGroupTodoUseCase.shared,
//            deleteGroupTodoUseCase: DefaultDeleteGroupTodoUseCase.shared,
//            updateGroupCategoryUseCase: DefaultUpdateGroupCategoryUseCase.shared
//        )
//        calendarViewModel.setGroupId(id: groupId)
//        let calendarViewController = JoinedGroupCalendarViewController(viewModel: calendarViewModel)
//        calendarViewController.delegate = self
//        calendarViewController.scrollDelegate = self
//        self.calendarViewController = calendarViewController
//        
////        let chattingViewController = JoinedGroupChattingViewController(nibName: nil, bundle: nil)
////        chattingViewController.scrollDelegate = self
////        self.chatViewController = chattingViewController
//        
//        childList.append(noticeViewController)
//        childList.append(calendarViewController)
////        childList.append(chattingViewController)
//        
//        pageViewController.setViewControllers([childList[0]], direction: .forward, animated: true)
//        currentIndex.onNext(0)
//
//        self.addChild(pageViewController)
//        pageViewController.willMove(toParent: self)
//        bottomView.addSubview(pageViewController.view)
//        
//        pageViewController.view.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//        
//        headerTabView.setTabs(tabs: ["공지사항", "그룹 캘린더"])
//    }
//    
//    func configureLayout() {
//        headerView.snp.makeConstraints {
//            $0.top.leading.trailing.equalToSuperview()
//            $0.height.equalTo(220 + UIApplication.shared.statusBarFrame.size.height + 44)
//        }
//        
//        headerTabView.snp.makeConstraints {
//            $0.bottom.equalTo(headerView.snp.bottom)
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(40)
//        }
//        
//        bottomView.snp.makeConstraints {
//            $0.top.equalTo(headerTabView.snp.bottom)
//            $0.leading.trailing.bottom.equalToSuperview()
//        }
//        
//        guard let headerViewHeightConstraint = headerView.constraints.first(where: { $0.firstAttribute == .height }) else { return }
//        self.headerViewHeightConstraint = headerViewHeightConstraint
//    }
//}
//
//extension JoinedGroupDetailViewController: JoinedGroupNoticeViewControllerDelegate {
//    func refreshRequested(_ viewController: JoinedGroupNoticeViewController) {
//        self.needRefresh.onNext(())
//    }
//    
//    func noticeViewControllerGetGroupTitle() -> String? {
//        viewModel?.groupTitle
//    }
//}
//
//
//extension JoinedGroupDetailViewController: UIPageViewControllerDataSource {
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        if let currentViewControllerIndex = childList.firstIndex(where: { $0 == viewController }) {
//            if (1..<childList.count).contains(currentViewControllerIndex) {
//                return childList[currentViewControllerIndex - 1]
//            }
//        }
//        return nil
//    }
//    
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        if let currentViewControllerIndex = childList.firstIndex(where: { $0 == viewController }) {
//            if (0..<(childList.count - 1)).contains(currentViewControllerIndex) {
//                return childList[currentViewControllerIndex + 1]
//            }
//        }
//        return nil
//    }
//}
//
////MARK:- Delegate Method to tell Inner View Controller movement inside Page View Controller
////Capture it and change the selection bar position in collection View
//
//extension JoinedGroupDetailViewController: UIPageViewControllerDelegate {
//    
//    func slideToPage(index: Int, completion: (() -> Void)?) {
//        guard let currentPageIndex = try? currentIndex.value() else { return }
//        let count = childList.count
//        if index < count {
//            if index > currentPageIndex {
//                let vc = childList[index]
//                    self.pageViewController.setViewControllers([vc], direction: .forward, animated: true, completion: { (complete) -> Void in
//                        self.currentIndex.onNext(index)
//                        completion?()
//                    })
//                
//            } else if index < currentPageIndex {
//                let vc = childList[index]
//                    self.pageViewController.setViewControllers([vc], direction: .reverse, animated: true, completion: { (complete) -> Void in
//                        self.currentIndex.onNext(index)
//                        completion?()
//                    })
//                
//            }
//        }
//    }
//    
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        guard completed else { return }
//        
//        guard let currentVC = pageViewController.viewControllers?.first else { return }
//        
//        guard let currentVCIndex = childList.firstIndex(where: { $0 == currentVC }) else { return }
//        currentIndex.onNext(currentVCIndex)
//    }
//}
//
//extension JoinedGroupDetailViewController: NestedScrollableViewScrollDelegate {
//    
//    var currentHeaderHeight: CGFloat? {
//        return headerViewHeightConstraint?.constant
//    }
//    
//    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
//        guard let headerViewHeightConstraint else { return }
//        headerViewHeightConstraint.constant -= scrollDistance
//        headerView.alpha = (headerViewHeightConstraint.constant - joinedGroupTopViewFinalHeight) / (joinedGroupTopViewInitialHeight - joinedGroupTopViewFinalHeight)
//        if headerViewHeightConstraint.constant < joinedGroupTopViewFinalHeight {
//            headerViewHeightConstraint.constant = joinedGroupTopViewFinalHeight
//        } else if headerViewHeightConstraint.constant >= joinedGroupTopViewInitialHeight {
//            headerViewHeightConstraint.constant = joinedGroupTopViewInitialHeight
//        }
//        
//        
//    }
////
//    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection) {
//        guard let headerViewHeightConstraint else { return }
//
//        let topViewHeight = headerViewHeightConstraint.constant
//
//        /*
//         *  Scroll is not restricted.
//         *  So this check might cause the view to get stuck in the header height is greater than initial height.
//
//        if topViewHeight >= topViewInitialHeight || topViewHeight <= topViewFinalHeight { return }
//
//        */
//
//        if topViewHeight >= joinedGroupTopViewInitialHeight {
//            scrollToInitialView()
//        }
//
//    }
//
//    func scrollToInitialView() {
//        guard let headerViewHeightConstraint else { return }
//
//        let topViewCurrentHeight = headerView.frame.height
//
//        let distanceToBeMoved = abs(topViewCurrentHeight - joinedGroupTopViewInitialHeight)
//
//        var time = distanceToBeMoved / 500
//
//        if time < 0.2 {
//
//            time = 0.2
//        }
//
//        headerViewHeightConstraint.constant = joinedGroupTopViewInitialHeight
//
////        UIView.animate(withDuration: TimeInterval(time), animations: {
////
////            self.view.layoutIfNeeded()
////        })
//    }
//
//    func scrollToFinalView() {
//        guard let headerViewHeightConstraint else { return }
//
//        let topViewCurrentHeight = headerView.frame.height
//
//        let distanceToBeMoved = abs(topViewCurrentHeight - joinedGroupTopViewFinalHeight)
//
//        var time = distanceToBeMoved / 500
//
//        if time < 0.2 {
//
//            time = 0.2
//        }
//
//        headerViewHeightConstraint.constant = joinedGroupTopViewFinalHeight
//
////        UIView.animate(withDuration: TimeInterval(time), animations: {
////
////            self.view.layoutIfNeeded()
////        })
//    }
//}
//
//extension JoinedGroupDetailViewController: JoinedGroupCalendarViewControllerDelegate {
//    func calendarViewControllerGetGroupTitle() -> String? {
//        return viewModel?.groupTitle
//    }
//    
//    func isLeader() -> Bool? {
//        return viewModel?.isLeader
//    }
//}
//
//extension JoinedGroupDetailViewController: JoinedGroupDetailHeaderTabDelegate {
//    func joinedGroupHeaderTappedAt(index: Int) {
//        slideToPage(index: index, completion: nil)
//    }
//}
//
//extension JoinedGroupDetailViewController: UIGestureRecognizerDelegate {}
//

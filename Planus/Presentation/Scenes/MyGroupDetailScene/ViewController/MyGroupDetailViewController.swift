//
//  MyGroupDetailViewController2.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/22.
//

import UIKit
import RxSwift

extension MyGroupDetailNavigatorType {
    var imageTitle: String {
        switch self {
        case .dot:
            return "menuHideBtn"
        case .notice:
            return "NoticeCircleBtn"
        case .calendar:
            return "CalendarCircleBtn"
        case .chat:
            return "ChatCircleBtn"
        }
    }
}

enum MyGroupDetailPageType: Int {
    case notice = 1
    case calendar = 2
    
    var attributes: [MyGroupDetailPageAttribute] {
        switch self {
        case .notice:
            return [.info, .notice, .member]
        case .calendar:
            return [.info, .calendar]
        }
    }
}

enum MyGroupDetailPageAttribute {
    case info
    case notice
    case member
    case calendar
    
    var sectionIndex: Int {
        switch self {
        case .info:
            return 0
        case .notice:
            return 1
        case .member:
            return 2
        case .calendar:
            return 1
        }
    }
    
    var headerTitle: String? {
        switch self {
        case .notice:
            return "공지사항"
        case .member:
            return "그룹멤버"
        default: return nil
        }
    }
    
    var headerMessage: String? {
        switch self {
        case .notice:
            return "우리 이렇게 진행해요"
        case .member:
            return "우리 이렇게 함께해요"
        default: return nil
        }
    }
}

class MyGroupDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    var bag = DisposeBag()
    
    let didChangedMonth = PublishSubject<Date>()
    var didSelectedDayAt = PublishSubject<Int>()
    var didSelectedMemberAt = PublishSubject<Int>()
    var didTappedOnlineButton = PublishSubject<Void>()
    
    var didTappedShareBtn = PublishSubject<Void>()
    var didTappedInfoEditBtn = PublishSubject<Void>()
    var didTappedMemberEditBtn = PublishSubject<Void>()
    var didTappedNoticeEditBtn = PublishSubject<Void>()
    
    var nowLoading: Bool = false
    
    var didTappedButtonAt = PublishSubject<Int>()
    var modeChanged: Bool = false
    
    let initialTrailing: CGFloat = -27
    let targetTrailing: CGFloat = 20
    var firstXOffset: CGFloat?
        
    lazy var buttonList: [UIButton] = {
        return MyGroupDetailNavigatorType.allCases.map { [weak self] in
            let image = UIImage(named: $0.imageTitle) ?? UIImage()
            let button = SpringableButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            button.setImage(image, for: .normal)
            button.tag = $0.rawValue
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            return button
        }
    }()
    
    var swipeBar: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "swipeBarLeft"))
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    var buttonsView: AnimatedStrechButtonListView = {
        let stretchButtonView = AnimatedStrechButtonListView(axis: .up)
        return stretchButtonView
    }()
    
    var viewModel: MyGroupDetailViewModel?
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())

        cv.register(GroupIntroduceNoticeCell.self,
            forCellWithReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier)
        
        cv.register(JoinedGroupMemberCell.self,
            forCellWithReuseIdentifier: JoinedGroupMemberCell.reuseIdentifier)
        
        cv.register(GroupIntroduceDefaultHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier)
        
        cv.register(MyGroupInfoHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: MyGroupInfoHeaderView.reuseIdentifier)
        
        cv.register(DailyCalendarCell.self, forCellWithReuseIdentifier: DailyCalendarCell.identifier)
        cv.register(JoinedGroupDetailCalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: JoinedGroupDetailCalendarHeaderView.reuseIdentifier)
        
        
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
        return cv
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .black
        return item
    }()
    
    convenience init(viewModel: MyGroupDetailViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureLayout()
        configureGestureRecognizer()
        
        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        let initialAppearance = UINavigationBarAppearance()
        let scrollingAppearance = UINavigationBarAppearance()
        scrollingAppearance.configureWithOpaqueBackground()
        scrollingAppearance.backgroundColor = UIColor(hex: 0xF5F5FB)
        let initialBarButtonAppearance = UIBarButtonItemAppearance()
        initialBarButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        initialAppearance.configureWithTransparentBackground()
        initialAppearance.buttonAppearance = initialBarButtonAppearance
        
        let scrollingBarButtonAppearance = UIBarButtonItemAppearance()
        scrollingBarButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
        scrollingAppearance.buttonAppearance = scrollingBarButtonAppearance
        self.navigationItem.standardAppearance = scrollingAppearance
        self.navigationItem.scrollEdgeAppearance = initialAppearance
        
        self.navigationController?.navigationBar.standardAppearance = scrollingAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = initialAppearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            viewModel?.actions.finishScene?()
        }
    }
        
    func bind() {
        guard let viewModel else { return }
        
        let input = MyGroupDetailViewModel.Input(
            viewDidLoad: Observable.just(()),
            didTappedModeBtnAt: didTappedButtonAt.asObservable(),
            didChangedMonth: didChangedMonth.asObservable(),
            didSelectedDayAt: didSelectedDayAt.asObservable(),
            didSelectedMemberAt: didSelectedMemberAt.asObservable(),
            didTappedOnlineButton: didTappedOnlineButton.asObservable(),
            didTappedShareBtn: didTappedShareBtn.asObservable(),
            didTappedInfoEditBtn: didTappedInfoEditBtn.asObservable(),
            didTappedMemberEditBtn: didTappedMemberEditBtn.asObservable(),
            didTappedNoticeEditBtn: didTappedNoticeEditBtn.asObservable(),
            backBtnTapped: backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message.text, type: Message.toToastType(state: message.state))
            })
            .disposed(by: bag)
        
        output
            .didInitialFetch
            .take(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                print("output initFetch")
                vc.nowLoading = false
                
                vc.setMenuButton(isLeader: viewModel.isLeader)
                
                guard let mode = viewModel.mode else { return }
                vc.setSectionCount(mode: mode, trailingAction: {
                    vc.collectionView.reloadSections(IndexSet(mode.attributes.map { $0.sectionIndex }))
                }, completion: {
                    vc.swipeBar.setAnimatedIsHidden(false, duration: 0.2)
                })
            })
            .disposed(by: self.bag)
        
        output
            .modeChanged
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                print("output mode")
                vc.modeChanged = true
            })
            .disposed(by: bag)
        
        output
            .didFetchInfo
            .compactMap { $0 }
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                print("output info")
                vc.nowLoading = false
                vc.collectionView.reloadSections(IndexSet(integer: 0))
            })
            .disposed(by: bag)
        
        output
            .didFetchNotice
            .compactMap { $0 }
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                print("output notice")
                guard let mode = viewModel.mode else { return }
                vc.nowLoading = false
                vc.setSectionCount(mode: mode, trailingAction: {
                    vc.collectionView.reloadSections(IndexSet(integer: MyGroupDetailPageAttribute.notice.sectionIndex))
                }, completion: {
                    if vc.modeChanged {
                        vc.modeChanged = false
                        vc.scrollToHeader(section: 1)
                    }
                })
            })
            .disposed(by: bag)
        
        // 모드 바꾸는 순서
        /*
         만약 데이터 없으면?
         섹션 갯수 줄이기 -> 바로 fetching
         섹션 갯수 줄이기 -> 로딩뷰 -> fetching
         */
        
        output
            .didFetchMember
            .compactMap { $0 }
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                print("output member")
                guard let mode = viewModel.mode else { return }
                vc.nowLoading = false
                vc.setSectionCount(mode: mode, trailingAction: {
                    vc.collectionView.reloadSections(IndexSet(integer: MyGroupDetailPageAttribute.member.sectionIndex))
                }, completion: {
                    if vc.modeChanged {
                        vc.modeChanged = false
                        vc.scrollToHeader(section: 1)
                    }
                })
            })
            .disposed(by: bag)
        
        output //모드 바꿀때 말고는 움직일 필요까진 없을듯한디,,,
            .didFetchCalendar
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                guard let mode = viewModel.mode else { return }
                vc.nowLoading = false
                viewModel.filteredWeeksOfYear = [Int](repeating: -1, count: 6)
                vc.setSectionCount(mode: mode, trailingAction: {
                    vc.collectionView.reloadSections(IndexSet(integer: MyGroupDetailPageAttribute.calendar.sectionIndex))
                }, completion: {
                    if vc.modeChanged {
                        vc.modeChanged = false
                        vc.scrollToHeader(section: 1)
                    }
                })
            })
            .disposed(by: bag)
        
        output
            .nowLoadingWithBefore
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, mode in
                print("output load")
                vc.nowLoading = true
                vc.setSectionCount(mode: mode, trailingAction: {
                    let indexSet = IndexSet(mode.attributes.filter { $0 != .info }.map { $0.sectionIndex })
                    vc.collectionView.reloadSections(indexSet)
                })
            })
            .disposed(by: bag)
        
        output
            .nowInitLoading
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                print("output initLoad")
                vc.nowLoading = true
                guard let mode = viewModel.mode else { return }
                vc.setSectionCount(mode: mode, trailingAction: {
                    let indexSet = IndexSet(mode.attributes.map { $0.sectionIndex })
                    vc.collectionView.reloadSections(indexSet)
                })
            })
            .disposed(by: bag)
        
        output
            .needReloadMemberAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.collectionView.reloadItems(at: [IndexPath(item: index, section: 2)])
            })
            .disposed(by: bag)
        
        output
            .memberKickedOutAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.collectionView.deleteItems(at: [IndexPath(item: index, section: 2)])
            })
            .disposed(by: bag)
        
        output
            .onlineStateChanged
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, isOnline in
                guard let view = vc.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? MyGroupInfoHeaderView else { return }
                view.onlineButton.isOn = isOnline
                view.onlineCountLabel.text = String(viewModel.onlineCount ?? 0)
                
            })
            .disposed(by: bag)
        
//        output
//            .showDailyPage
//            .observe(on: MainScheduler.asyncInstance)
//            .withUnretained(self)
//            .subscribe(onNext: { vc, date in
                
//                guard let groupId = viewModel.groupId,
//                      let groupName = viewModel.groupTitle,
//                      let isOwner = viewModel.isLeader else { return }
//                let nm = NetworkManager()
//                let kc = KeyChainManager()
//                let tokenRepo = DefaultTokenRepository(apiProvider: nm, keyValueStorage: kc)
//                let gcr = DefaultGroupCalendarRepository(apiProvider: nm)
//                let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
//                let refTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
//                let fetchGroupDailyTodoListUseCase = DefaultFetchGroupDailyCalendarUseCase(groupCalendarRepository: gcr)
//                let fetchMemberDailyCalendarUseCase = DefaultFetchGroupMemberDailyCalendarUseCase(memberCalendarRepository: DefaultGroupMemberCalendarRepository(apiProvider: nm))
//                let viewModel = SocialTodoDailyViewModel(
//                    getTokenUseCase: getTokenUseCase,
//                    refreshTokenUseCase: refTokenUseCase,
//                    fetchGroupDailyTodoListUseCase: fetchGroupDailyTodoListUseCase,
//                    fetchMemberDailyCalendarUseCase: fetchMemberDailyCalendarUseCase,
//                    createGroupTodoUseCase: DefaultCreateGroupTodoUseCase.shared,
//                    updateGroupTodoUseCase: DefaultUpdateGroupTodoUseCase.shared,
//                    deleteGroupTodoUseCase: DefaultDeleteGroupTodoUseCase.shared,
//                    updateGroupCategoryUseCase: DefaultUpdateGroupCategoryUseCase.shared
//                )
//                viewModel.setGroup(group: GroupName(groupId: groupId, groupName: groupName), type: .group(isLeader: isOwner), date: date)
//                let viewController = SocialTodoDailyViewController(viewModel: viewModel)
//                
//                let nav = UINavigationController(rootViewController: viewController)
//                nav.modalPresentationStyle = .pageSheet
//                if let sheet = nav.sheetPresentationController {
//                    sheet.detents = [.medium(), .large()]
//                }
////                vc.present(nav, animated: true)
//            })
//            .disposed(by: bag)
        
        output
            .showShareMenu
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vc, url in
                vc.showShareActivityVC(with: url)
            })
            .disposed(by: bag)

    }
    
    func setSectionCount(mode: MyGroupDetailPageType, trailingAction: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        let newSectionCount = mode.attributes.count
        let currentSectionCount = collectionView.numberOfSections

        collectionView.performBatchUpdates({
            if newSectionCount < currentSectionCount {
                collectionView.deleteSections(IndexSet(newSectionCount..<currentSectionCount))
            } else if newSectionCount > currentSectionCount {
                collectionView.insertSections(IndexSet(currentSectionCount..<newSectionCount))
            }
            trailingAction?()
        }, completion: { _ in completion?() })
    }
    
    func showShareActivityVC(with url: String) {
        var objectsToShare = [String]()
        objectsToShare.append(url)
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
        DispatchQueue.main.async { [weak self] in
            self?.present(activityVC, animated: true)
        }
    }
    
    func scrollToHeader(section: Int) {
        guard let layoutAttributes =  collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 1)) else { return }
        let viewOrigin = CGPoint(x: layoutAttributes.frame.origin.x, y: layoutAttributes.frame.origin.y);
        var offset = collectionView.contentOffset;
        let height = (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + (navigationController?.navigationBar.frame.height ?? 0)
        offset.y = viewOrigin.y - collectionView.contentInset.top - height
        collectionView.setContentOffset(offset, animated: true)
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(collectionView)
        self.view.addSubview(buttonsView)
        buttonList.forEach {
            buttonsView.addButton(button: $0)
        }
        self.view.addSubview(swipeBar)
        
        buttonsView.isHidden = true
        swipeBar.isHidden = true
    }
    
    func configureGestureRecognizer() {
        let sgr = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        sgr.direction = .left
        swipeBar.addGestureRecognizer(sgr)
    }
    
    func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        swipeBar.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(30)
        }

        buttonsView.snp.makeConstraints {
            $0.centerY.equalTo(swipeBar)
            $0.trailing.equalToSuperview().inset(initialTrailing)
        }
    }
    @objc func swipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.direction == .left {
            showModeSelection()
        }
    }
    
    func showModeSelection() {
        self.buttonsView.alpha = 0
        self.buttonsView.isHidden = false
        self.buttonsView.stretch()
        
        buttonsView.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(50)
            $0.trailing.equalTo(self.view).inset(targetTrailing)
        }
        
        swipeBar.snp.remakeConstraints {
            $0.leading.equalTo(self.view.snp.trailing)
            $0.bottom.equalToSuperview().inset(30)
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonsView.alpha = 1
        })
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    func hideModeSelection() {
        buttonsView.shrink { [weak self] in
            self?.buttonsView.snp.remakeConstraints {
                $0.bottom.equalToSuperview().inset(50)
                $0.trailing.equalToSuperview().inset(self?.initialTrailing ?? 0)
            }
            self?.swipeBar.snp.remakeConstraints {
                $0.trailing.equalToSuperview()
                $0.bottom.equalToSuperview().inset(30)
            }
            UIView.animate(withDuration: 0.1, delay: 0.1, animations: {
                self?.buttonsView.alpha = 0
            }, completion: { _ in
                self?.buttonsView.isHidden = true
            })
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self?.view.layoutIfNeeded()
            })
        }
        
    }
    
    
    @objc func buttonTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            hideModeSelection()
        } else {
            didTappedButtonAt.onNext(sender.tag)
        }
    }
}

extension MyGroupDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let mode = viewModel?.mode else { return false }
        
        switch mode {
        case .notice:
            if indexPath.section == MyGroupDetailPageAttribute.member.sectionIndex {
                didSelectedMemberAt.onNext(indexPath.item)
            }
        case .calendar:
            if indexPath.section == MyGroupDetailPageAttribute.calendar.sectionIndex {
                didSelectedDayAt.onNext(indexPath.item)
            }
        }

        return false
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.mode?.attributes.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let mode = viewModel?.mode else { return 0 }
        
        switch mode.attributes[section] {
        case .info: return 0
        case .notice: return nowLoading ? 1 : (viewModel?.notice != nil) ? 1 : 0
        case .member: return nowLoading ? 6 : (viewModel?.memberList?.count ?? 0)
        case .calendar: return nowLoading ? 42 : (viewModel?.mainDayList.count ?? 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let mode = viewModel?.mode else { return UICollectionViewCell() }
        
        switch mode.attributes[indexPath.section] {
        case .info: return UICollectionViewCell()
        case .notice:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier, for: indexPath) as? GroupIntroduceNoticeCell else { return UICollectionViewCell() }
            if nowLoading {
                cell.startSkeletonAnimation()
                return cell
            }
            
            guard let item = viewModel?.notice else { return UICollectionViewCell() }
            print("stop notice skele")
            cell.stopSkeletonAnimation()
            cell.fill(notice: item)
            return cell
        case .member:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JoinedGroupMemberCell.reuseIdentifier, for: indexPath) as? JoinedGroupMemberCell else { return UICollectionViewCell() }
            if nowLoading {
                cell.startSkeletonAnimation()
                return cell
            } // nowLoading을 처음부터 true로? 아니면 갯술
            
            guard let item = viewModel?.memberList?[indexPath.item] else { return UICollectionViewCell() }
            cell.stopSkeletonAnimation()
            
            cell.fill(name: item.nickname, introduce: item.description, isCaptin: item.isLeader, isOnline: item.isOnline)
            
            if let url = item.profileImageUrl {
                viewModel?.fetchImage(key: url)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onSuccess: { data in
                        cell.fill(image: UIImage(data: data))
                    })
                    .disposed(by: bag)
            } else {
                cell.fill(image: UIImage(named: "DefaultProfileMedium"))
            }
            
            return cell
        case .calendar:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCell.identifier, for: indexPath) as? DailyCalendarCell else {
                return UICollectionViewCell()
            }
            if nowLoading {
                cell.startSkeletonAnimation()
                return cell
            }
            cell.stopSkeletonAnimation()
            
            return calendarCell(cell: cell, indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let mode = viewModel?.mode else { return UICollectionViewCell() }
        
        switch mode.attributes[indexPath.section] {
        case .info:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MyGroupInfoHeaderView.reuseIdentifier, for: indexPath) as? MyGroupInfoHeaderView else { return UICollectionReusableView() }
            if nowLoading {
                view.startSkeletonAnimation()
                return view
            }
            
            view.stopSkeletonAnimation()
            
            let viewBag = DisposeBag()
            view.viewBag = viewBag
            view.fill(
                title: viewModel?.groupTitle ?? "",
                tag: viewModel?.tag?.map { "#\($0)" }.joined(separator: " ") ?? "",
                memCount: String(viewModel?.memberCount ?? 0),
                captin: viewModel?.leaderName ?? "",
                onlineCount: String(viewModel?.onlineCount ?? 0),
                isOnline: (try? viewModel?.isOnline.value()) ?? false
            )
            
            if let url = viewModel?.groupImageUrl {
                viewModel?.fetchImage(key: url)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onSuccess: { data in
                        view.fill(image: UIImage(data: data))
                    })
                    .disposed(by: viewBag)
            }
            
            view.onlineButton
                .rx.tap
                .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
                .withUnretained(self)
                .subscribe(onNext: { vc, _ in
                    view.onlineButton.isOn = !view.onlineButton.isOn
                    vc.didTappedOnlineButton.onNext(())
                })
                .disposed(by: viewBag)
            
            return view
        case .notice, .member:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier, for: indexPath) as? GroupIntroduceDefaultHeaderView else { return UICollectionReusableView() }
            if nowLoading {
                view.startSkeletonAnimation()
                return view
            }
            view.stopSkeletonAnimation()
            view.fill(title: mode.attributes[indexPath.section].headerTitle, description: mode.attributes[indexPath.section].headerMessage)
            return view
        case .calendar:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: JoinedGroupDetailCalendarHeaderView.reuseIdentifier, for: indexPath) as? JoinedGroupDetailCalendarHeaderView else { return UICollectionReusableView() }
            
            if nowLoading {
                view.startSkeletonAnimation()
                return view
            }
            
            view.stopSkeletonAnimation()
            
            let bag = DisposeBag()
            view.yearMonthButton.setTitle(viewModel?.currentDateText, for: .normal)
            view.yearMonthButton.rx.tap
                .withUnretained(self)
                .subscribe(onNext: { vc, _ in
                    
                    let dateMonth = vc.viewModel?.currentDate ?? Date()
                    let firstMonth = Calendar.current.date(byAdding: DateComponents(month: -100), to: dateMonth) ?? Date()
                    let lastMonth = Calendar.current.date(byAdding: DateComponents(month: 500), to: dateMonth) ?? Date()
                    
                    let viewController = MonthPickerViewController(firstYear: firstMonth, lastYear: lastMonth, currentDate: dateMonth) { date in
                        vc.didChangedMonth.onNext(date)
                    }

                    viewController.preferredContentSize = CGSize(width: 320, height: 290)
                    viewController.modalPresentationStyle = .popover
                    let popover: UIPopoverPresentationController = viewController.popoverPresentationController!
                    popover.delegate = vc
                    popover.sourceView = vc.view
                    
                    let globalFrame = view.yearMonthButton.convert(view.yearMonthButton.bounds, to: vc.view)

                    popover.sourceRect = CGRect(x: globalFrame.midX, y: globalFrame.maxY, width: 0, height: 0)
                    popover.permittedArrowDirections = [.up]
                    vc.present(viewController, animated: true, completion:nil)
                })
                .disposed(by: bag)
            view.bag = bag
            return view
        }
        
        
        

        
    }
}


extension MyGroupDetailViewController {
    func setMenuButton(isLeader: Bool?) {
        let image = UIImage(named: "dotBtn")
        var item: UIBarButtonItem
        var menuChild = [UIAction]()
        
        let share = UIAction(title: "공유하기", image: UIImage(systemName: "square.and.arrow.up"), handler: { [weak self] _ in
            self?.didTappedShareBtn.onNext(())
        })
        menuChild.append(share)

        if isLeader ?? false {
            [
                UIAction(
                    title: "그룹 정보 수정",
                    image: UIImage(systemName: "pencil"),
                    handler: { [weak self] _ in
                        self?.didTappedInfoEditBtn.onNext(())
                    }
                ),
                
                UIAction(
                    title: "공지사항 수정",
                    image: UIImage(systemName: "speaker.badge.exclamationmark.fill"),
                    handler: { [weak self] _ in
                        self?.didTappedNoticeEditBtn.onNext(())
                    }
                ),
                UIAction(
                    title: "멤버 수정",
                    image: UIImage(systemName: "person"),
                    handler: { [weak self] _ in
                        self?.didTappedMemberEditBtn.onNext(())
                    }
                )
            ]
                .forEach {
                    menuChild.append($0)
                }
        } else {
            let withdraw = UIAction(
                title: "그룹 탈퇴하기",
                image: UIImage(systemName: "rectangle.portrait.and.arrow.forward"),
                attributes: .destructive,
                handler: { [weak self] _ in
                    self?.withdrawGroup()
                })
            
            menuChild.append(withdraw)
        }
        
        let menu = UIMenu(options: .displayInline, children: menuChild)
        item = UIBarButtonItem(image: image, menu: menu)
        item.tintColor = UIColor(hex: 0x000000)
        navigationItem.setRightBarButton(item, animated: true)
    }
    
    func withdrawGroup() {
        self.showPopUp(title: "그룹 탈퇴하기", message: "정말로 그룹을 탈퇴하시겠습니까?", alertAttrs: [
            CustomAlertAttr(title: "취소", actionHandler: {}, type: .normal),
            CustomAlertAttr(title: "탈퇴", actionHandler: { [weak self] in self?.viewModel?.withdrawGroup()}, type: .warning)]
        )
    }
}

extension MyGroupDetailViewController {
    private func createInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(1), heightDimension: .absolute(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(1),heightDimension: .absolute(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(330))

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [sectionHeader]
                
        return section
    }
    
    private func createNoticeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 30, trailing: 0)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(70))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }
    
    private func createMemberSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(66))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 26, bottom: 0, trailing: 26)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 85, trailing: 0)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(70))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }
    
    private func createCalendarSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(Double(1)/Double(7)),
            heightDimension: .estimated(110)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(110)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
                
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(80))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createLoadSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return StickyTopCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self,
                  let mode = self.viewModel?.mode else { return nil }

            switch mode.attributes[sectionIndex] {
            case .info:
                return self.createInfoSection()
            case .notice:
                return self.createNoticeSection()
            case .member:
                return self.createMemberSection()
            case .calendar:
                return self.createCalendarSection()
            }
        }
    }
}

extension MyGroupDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension MyGroupDetailViewController {
    func calendarCell(cell: DailyCalendarCell, indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel else { return UICollectionViewCell() }
        let screenWidth = UIScreen.main.bounds.width
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let currentDate = viewModel.mainDayList[indexPath.item].date
        if viewModel.filteredWeeksOfYear[indexPath.item/7] != calendar.component(.weekOfYear, from: currentDate) {
            viewModel.filteredWeeksOfYear[indexPath.item/7] = calendar.component(.weekOfYear, from: currentDate)
            (indexPath.item - indexPath.item%7..<indexPath.item - indexPath.item%7 + 7).forEach {
                viewModel.blockMemo[$0] = [Int?](repeating: nil, count: 20)
            }
            for (item, day) in Array(viewModel.mainDayList.enumerated())[indexPath.item - indexPath.item%7..<indexPath.item - indexPath.item%7 + 7] {
                var filteredTodoList = viewModel.todos[day.date] ?? []
                
                var periodList = filteredTodoList.filter { $0.startDate != $0.endDate }
                let singleList = filteredTodoList.filter { $0.startDate == $0.endDate }
                
                if item % 7 != 0 { // 만약 월요일이 아닐 경우, 오늘 시작하는것들만, 월요일이면 포함되는 전체 다!
                    periodList = periodList.filter { $0.startDate == day.date }
                        .sorted { $0.endDate < $1.endDate }
                } else { //월요일 중에 오늘이 startDate가 아닌 놈들만 startDate로 정렬, 그 뒤에는 전부다 endDate로 정렬하고, 이걸 다시 endDate를 업댓해줘야함!
                    
                    var continuousPeriodList = periodList
                        .filter { $0.startDate != day.date }
                        .sorted{ ($0.startDate == $1.startDate) ? $0.endDate < $1.endDate : $0.startDate < $1.startDate }
                        .map { todo in
                            var tmpTodo = todo
                            tmpTodo.startDate = day.date
                            return tmpTodo
                        }
                    
                    var initialPeriodList = periodList
                        .filter { $0.startDate == day.date } //이걸 바로 end로 정렬해도 되나? -> 애를 바로 end로 정렬할 경우?
                        .sorted{ $0.endDate < $1.endDate }
                    
                    periodList = continuousPeriodList + initialPeriodList
                }
                
                periodList = periodList.map { todo in
                    let currentWeek = calendar.component(.weekOfYear, from: day.date)
                    let endWeek = calendar.component(.weekOfYear, from: todo.endDate)
                    
                    if currentWeek != endWeek {
                        let firstDayOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: day.date))
                        let lastDayOfWeek = calendar.date(byAdding: .day, value: 6, to: firstDayOfWeek!) //이게 이번주 일요일임.
                        var tmpTodo = todo
                        tmpTodo.endDate = lastDayOfWeek!
                        return tmpTodo
                    } else { return todo }
                }
                
                let periodTodo: [(Int, SocialTodoSummary)] = periodList.compactMap { todo in
                    for i in (0..<viewModel.blockMemo[item].count) {
                        if viewModel.blockMemo[item][i] == nil,
                           let period = Calendar.current.dateComponents([.day], from: todo.startDate, to: todo.endDate).day {
                            for j in (0...period) {
                                viewModel.blockMemo[item+j][i] = todo.todoId
                            }
                            return (i, todo)
                        }
                    }
                    return nil
                }
                
                var singleStartIndex = 0
                viewModel.blockMemo[item].enumerated().forEach { (index, tuple) in
                    if tuple != nil {
                        singleStartIndex = index + 1
                    }
                }
                
                let singleTodo = singleList.enumerated().map { (index, todo) in
                    return (index + singleStartIndex, todo)
                }
                
                var holidayMock: (Int, String)?
                if let holidayTitle = HolidayPool.shared.holidays[day.date] {
                    let holidayIndex = singleStartIndex + singleTodo.count
                    holidayMock = (holidayIndex, holidayTitle)
                }
                
                viewModel.filteredTodoCache[item] = FilteredSocialTodoViewModel(periodTodo: periodTodo, singleTodo: singleTodo, holiday: holidayMock)
            }
        }
        
        let weekRange = (indexPath.item - indexPath.item%7..<indexPath.item - indexPath.item%7 + 7)
        
        guard let maxItem = viewModel.filteredTodoCache[weekRange]
            .max(by: { a, b in
                let aHeight = (a.holiday != nil) ? a.holiday!.0 : (a.singleTodo.last != nil) ?
                a.singleTodo.last!.0 : (a.periodTodo.last != nil) ? a.periodTodo.last!.0 : 0
                let bHeight = (b.holiday != nil) ? b.holiday!.0 : (b.singleTodo.last != nil) ?
                b.singleTodo.last!.0 : (b.periodTodo.last != nil) ? b.periodTodo.last!.0 : 0
                return aHeight < bHeight
            }) else { return UICollectionViewCell() }
                
        guard var todosHeight = (maxItem.holiday != nil) ?
                maxItem.holiday?.0 : (maxItem.singleTodo.count != 0) ?
                maxItem.singleTodo.last?.0 : (maxItem.periodTodo.count != 0) ?
                maxItem.periodTodo.last?.0 : 0 else { return UICollectionViewCell() }
        
        var height: CGFloat
        if let cellHeight = viewModel.cachedCellHeightForTodoCount[todosHeight] {
            height = cellHeight
        } else {
            let mockCell = DailyCalendarCell(mockFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * UIScreen.main.bounds.width, height: 110))
            mockCell.socialFill(
                periodTodoList: maxItem.periodTodo,
                singleTodoList: maxItem.singleTodo,
                holiday: maxItem.holiday
            )
            
            mockCell.layoutIfNeeded()
            
            let estimatedSize = mockCell.systemLayoutSizeFitting(CGSize(
                width: Double(1)/Double(7) * UIScreen.main.bounds.width,
                height: UIView.layoutFittingCompressedSize.height
            ))
            let estimatedHeight = estimatedSize.height + mockCell.stackView.topY + 3
            let targetHeight = (estimatedHeight > 110) ? estimatedHeight : 110
            height = targetHeight
        }
        
        let day = viewModel.mainDayList[indexPath.item]
        let filteredTodo = viewModel.filteredTodoCache[indexPath.item]
        
        cell.fill(
            day: "\(Calendar.current.component(.day, from: day.date))",
            state: day.state,
            weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: day.date)+5)%7)!,
            isToday: day.date == viewModel.today,
            isHoliday: HolidayPool.shared.holidays[day.date] != nil,
            height: height
        )
        
        cell.socialFill(periodTodoList: filteredTodo.periodTodo, singleTodoList: filteredTodo.singleTodo, holiday: filteredTodo.holiday)
        return cell
    }
}

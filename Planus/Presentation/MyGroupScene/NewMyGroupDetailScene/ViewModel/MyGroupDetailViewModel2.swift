//
//  MyGroupDetailViewModel2.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/22.
//

import Foundation
import RxSwift

enum MyGroupDetailNavigatorType: Int, CaseIterable { //일케하면 데드락 생길수도 있음. 로딩을 분리? 아니면 아에 fetch 메서드를 다르게 가져갈까?
    // 이걸로 구분하면 0눌렀을때 로딩중 바뀌고 fetch 시작, 다되기 전에 1눌러서 fetch 시작, 그럼 1결과를 보여주기 전에 0을 먼저 보여줄 수 있음.
    case dot = 0
    case notice
    case calendar
    case chat
}

enum MyGroupSecionType {
    case info
    case notice
    case member
    case calendar
    case chat
}

class MyGroupDetailViewModel2 {
    let bag = DisposeBag()
    var actions: JoinedGroupDetailViewModelActions?

    struct Input {
        var viewDidLoad: Observable<Void>
        var didTappedModeBtnAt: Observable<Int>
        var didChangedMonth: Observable<Date>
        var didSelectedDayAt: Observable<Int>
        var didSelectedMemberAt: Observable<Int>
        var didTappedOnlineButton: Observable<Void>
        var shareBtnTapped: Observable<Void>
    }
    
    struct Output {
        var showMessage: Observable<Message>
        var didInitialFetch: Observable<Void>
        var didFetchInfo: Observable<Void?>
        var didFetchNotice: Observable<Void?>
        var didFetchMember: Observable<Void?>
        var didFetchCalendar: Observable<Void?>
        var nowLoadingWithBefore: Observable<MyGroupDetailPageType?>
        var showDailyPage: Observable<Date>
        var showMemberProfileAt: Observable<Int>
        var memberKickedOutAt: Observable<Int>
        var needReloadMemberAt: Observable<Int>
        var onlineStateChanged: Observable<Bool?>
        var modeChanged: Observable<Void>
        var showShareMenu: Observable<String?>
        var nowInitLoading: Observable<Void?>
    }
    
    var nowLoadingWithBefore = BehaviorSubject<MyGroupDetailPageType?>(value: nil)
    var nowInitLoading = BehaviorSubject<Void?>(value: nil)
    
    var didFetchInfo = BehaviorSubject<Void?>(value: nil)
    var didFetchNotice = BehaviorSubject<Void?>(value: nil)
    var didFetchMember = BehaviorSubject<Void?>(value: nil)
    var didFetchCalendar = BehaviorSubject<Void?>(value: nil)
    var showShareMenu = PublishSubject<String?>()
    
    var groupId: Int?
    var groupTitle: String?
    var groupImageUrl: String?
    var tag: [String]?
    var memberCount: Int?
    var limitCount: Int?
    var leaderName: String?
    var isLeader: Bool?
    
    var onlineCount: Int?
    
    var isOnline = BehaviorSubject<Bool?>(value: nil)
    
    // MARK: mode 0, notice section
    var notice: String?
    var memberList: [MyMember]?
    var memberKickedOutAt = PublishSubject<Int>()
    var needReloadMemberAt = PublishSubject<Int>()
    var showDailyPage = PublishSubject<Date>()
    var showMemberProfileAt = PublishSubject<Int>()
        
    // MARK: mode1, calendar section
    var today: Date = {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    var currentDate: Date?
    var currentDateText: String?
    var mainDayList = [DayViewModel]()
    var todos = [Date: [SocialTodoSummary]]()
    
    var blockMemo = [[Int?]](repeating: [Int?](repeating: nil, count: 20), count: 42)
    
    var filteredWeeksOfYear = [Int](repeating: -1, count: 6)
    var filteredTodoCache = [FilteredSocialTodoViewModel](repeating: FilteredSocialTodoViewModel(periodTodo: [], singleTodo: []), count: 42)
    var cachedCellHeightForTodoCount = [Int: Double]()
        
    var showDaily = PublishSubject<Date>()
    
    var mode: MyGroupDetailPageType?
    
    let showMessage = PublishSubject<Message>()
    let modeChanged = PublishSubject<Void>()
    
    
    
    var fetchMyGroupDetailUseCase: FetchMyGroupDetailUseCase
    var updateNoticeUseCase: UpdateNoticeUseCase
    var updateInfoUseCase: UpdateGroupInfoUseCase
    var withdrawGroupUseCase: WithdrawGroupUseCase
    
    var fetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase
    var fetchImageUseCase: FetchImageUseCase
    var memberKickOutUseCase: MemberKickOutUseCase
    var setOnlineUseCase: SetOnlineUseCase
    
    
    let getTokenUseCase: GetTokenUseCase
    let refreshTokenUseCase: RefreshTokenUseCase
    let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
    let fetchMyGroupCalendarUseCase: FetchGroupMonthlyCalendarUseCase
    
    let createGroupTodoUseCase: CreateGroupTodoUseCase
    let updateGroupTodoUseCase: UpdateGroupTodoUseCase
    let deleteGroupTodoUseCase: DeleteGroupTodoUseCase
    let updateGroupCategoryUseCase: UpdateGroupCategoryUseCase
    
    let generateGroupLinkUseCase: GenerateGroupLinkUseCase
    
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchMyGroupDetailUseCase: FetchMyGroupDetailUseCase,
        fetchImageUseCase: FetchImageUseCase,
        setOnlineUseCase: SetOnlineUseCase,
        updateNoticeUseCase: UpdateNoticeUseCase,
        updateInfoUseCase: UpdateGroupInfoUseCase,
        withdrawGroupUseCase: WithdrawGroupUseCase,
        fetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase,
        memberKickOutUseCase: MemberKickOutUseCase,
        createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase,
        fetchMyGroupCalendarUseCase: FetchGroupMonthlyCalendarUseCase,
        createGroupTodoUseCase: CreateGroupTodoUseCase,
        updateGroupTodoUseCase: UpdateGroupTodoUseCase,
        deleteGroupTodoUseCase: DeleteGroupTodoUseCase,
        updateGroupCategoryUseCase: UpdateGroupCategoryUseCase,
        generateGroupLinkUseCase: GenerateGroupLinkUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchMyGroupDetailUseCase = fetchMyGroupDetailUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.setOnlineUseCase = setOnlineUseCase
        self.updateInfoUseCase = updateInfoUseCase
        self.updateNoticeUseCase = updateNoticeUseCase
        self.withdrawGroupUseCase = withdrawGroupUseCase
        self.fetchMyGroupMemberListUseCase = fetchMyGroupMemberListUseCase
        self.memberKickOutUseCase = memberKickOutUseCase
        self.createMonthlyCalendarUseCase = createMonthlyCalendarUseCase
        self.fetchMyGroupCalendarUseCase = fetchMyGroupCalendarUseCase
        self.createGroupTodoUseCase = createGroupTodoUseCase
        self.updateGroupTodoUseCase = updateGroupTodoUseCase
        self.deleteGroupTodoUseCase = deleteGroupTodoUseCase
        self.updateGroupCategoryUseCase = updateGroupCategoryUseCase
        self.generateGroupLinkUseCase = generateGroupLinkUseCase
    }
    
    func transform(input: Input) -> Output {
        
        bindUseCase()
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let groupId = vm.groupId else { return }
                vm.mode = .notice
                vm.nowInitLoading.onNext(())
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    vm.fetchGroupDetail(groupId: groupId, fetchType: .initail)
                    vm.fetchMemberList()
                })
            })
            .disposed(by: bag)

        input
            .didTappedModeBtnAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                let mode = MyGroupDetailPageType(rawValue: index)
                vm.mode = mode
                vm.modeChanged.onNext(())
                switch mode {
                case .notice:
                    if vm.memberList?.isEmpty ?? true {
                        vm.nowLoadingWithBefore.onNext(vm.mode)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            vm.fetchMemberList()
                        })
                    } else {
                        vm.mode = .notice
                        vm.didFetchNotice.onNext(())
                    }
                case .calendar:
                    if vm.mainDayList.isEmpty {
                        vm.nowLoadingWithBefore.onNext(mode)
                        let components = Calendar.current.dateComponents(
                            [.year, .month],
                            from: Date()
                        )
                        
                        let currentDate = Calendar.current.date(from: components) ?? Date()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            vm.createCalendar(date: currentDate)
                        })
                        
                    } else {
                        vm.didFetchCalendar.onNext(())
                    }
                default: return
                }
            })
            .disposed(by: bag)
        
        input
            .didChangedMonth
            .withUnretained(self)
            .subscribe(onNext: { vm, date in
                vm.mode = .calendar
                vm.createCalendar(date: date)
            })
            .disposed(by: bag)
        
        input
            .didSelectedMemberAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.showMemberProfileAt.onNext(index)
            })
            .disposed(by: bag)
        
        input
            .didSelectedDayAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                let date = vm.mainDayList[index].date
                vm.showDailyPage.onNext(date)
            })
            .disposed(by: bag)
        
        input
            .didTappedOnlineButton
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.flipOnlineState()
            })
            .disposed(by: bag)
        
        input
            .shareBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                let urlString = vm.generateShareLink()
                vm.showShareMenu.onNext(urlString)
            })
            .disposed(by: bag)
        
        let initFetched = Observable.zip( //만약 먼저 방출하면? 어케되는거지????? 으으으음,,,, 상관없나??? 일단 해보자..!
            didFetchInfo.compactMap { $0 },
            didFetchNotice.compactMap { $0 },
            didFetchMember.compactMap { $0 }
        )
            .map { _ in () }
        //그대로 하고 메인스레드에서 구독을 좀 늦춰서 실험 ㄱㄱ
        
        return Output(
            showMessage: showMessage.asObservable(),
            didInitialFetch: initFetched,
            didFetchInfo: didFetchInfo.asObservable(),
            didFetchNotice: didFetchNotice.asObservable(),
            didFetchMember: didFetchMember.asObservable(),
            didFetchCalendar: didFetchCalendar.asObservable(),
            nowLoadingWithBefore: nowLoadingWithBefore.asObservable(),
            showDailyPage: showDailyPage.asObservable(),
            showMemberProfileAt: showMemberProfileAt.asObservable(),
            memberKickedOutAt: memberKickedOutAt.asObservable(),
            needReloadMemberAt: needReloadMemberAt.asObservable(),
            onlineStateChanged: isOnline.asObservable(),
            modeChanged: modeChanged.asObservable(),
            showShareMenu: showShareMenu.asObservable(),
            nowInitLoading: nowInitLoading.asObservable()
        )
    }
    
    func generateShareLink() -> String? {
        guard let groupId = groupId else { return nil }
        return generateGroupLinkUseCase.execute(groupId: groupId)
    }
    
    func bindUseCase() {
        setOnlineUseCase
            .didChangeOnlineState
            .withUnretained(self)
            .subscribe(onNext: { vm, arg in
                let (groupId, memberId) = arg
                if groupId == vm.groupId {
                    guard let exValue = try? vm.isOnline.value(),
                          let onlineCount = vm.onlineCount else { return }
                    let newValue = !exValue
                    
                    vm.onlineCount = newValue ? (onlineCount + 1) : (onlineCount - 1)
                    vm.isOnline.onNext(newValue)
                    
                    vm.showMessage.onNext(Message(text: "\(vm.groupTitle ?? "") 그룹을 \(newValue ? "온" : "오프")라인으로 전환하였습니다.", state: .normal))
                    guard let index = vm.memberList?.firstIndex(where: { $0.memberId == memberId }),
                          var member = vm.memberList?[index] else { return }
                    
                    member.isOnline = !member.isOnline
                    vm.memberList?[index] = member
                    
                    if vm.mode == .notice {
                        vm.needReloadMemberAt.onNext(index)
                    }
                }
            })
            .disposed(by: bag)
        
        updateNoticeUseCase
            .didUpdateNotice
            .withUnretained(self)
            .subscribe(onNext: { vm, groupNotice in
                guard let id = vm.groupId,
                      id == groupNotice.groupId else { return }
                vm.notice = groupNotice.notice
                if vm.mode == .notice {
                    vm.didFetchNotice.onNext(())
                    vm.showMessage.onNext(Message(text: "공지사항을 업데이트 하였습니다.", state: .normal))
                }
            })
            .disposed(by: bag)
        
        updateInfoUseCase
            .didUpdateInfoWithId
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                guard id == vm.groupId else { return }
                vm.fetchGroupDetail(groupId: id, fetchType: .update)
            })
            .disposed(by: bag)
        
        createGroupTodoUseCase
            .didCreateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.groupId == todo.groupId else { return }
                let startDate = vm.mainDayList.first?.date ?? Date()
                let endDate = vm.mainDayList.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        updateGroupTodoUseCase // 삭제하고 다시넣기,,, 걍 다시받는게 편하겠지 아무래도?
            .didUpdateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.groupId == todo.groupId else { return }
                let startDate = vm.mainDayList.first?.date ?? Date()
                let endDate = vm.mainDayList.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        deleteGroupTodoUseCase
            .didDeleteGroupTodoWithIds
            .withUnretained(self)
            .subscribe(onNext: { vm, ids in
                guard vm.groupId == ids.groupId else { return }
                let startDate = vm.mainDayList.first?.date ?? Date()
                let endDate = vm.mainDayList.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        updateGroupCategoryUseCase
            .didUpdateCategoryWithGroupId
            .withUnretained(self)
            .subscribe(onNext: { vm, categoryWithGroupId in
                guard vm.groupId == categoryWithGroupId.groupId else { return }
                let startDate = vm.mainDayList.first?.date ?? Date()
                let endDate = vm.mainDayList.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        memberKickOutUseCase
            .didKickOutMemberAt
            .withUnretained(self)
            .subscribe(onNext: { vm, args in
                let (groupId, memberId) = args
                guard let currentGroupId = vm.groupId,
                      groupId == currentGroupId,
                      let index = vm.memberList?.firstIndex(where: { $0.memberId == memberId }) else { return }
                vm.memberList?.remove(at: index)
                if vm.mode == .notice {
                    vm.memberKickedOutAt.onNext(index)
                }
            })
            .disposed(by: bag)
        
    }
    
    func setActions(actions: JoinedGroupDetailViewModelActions) {
        self.actions = actions
    }
    
    func fetchGroupDetail(groupId: Int, fetchType: FetchType) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<MyGroupDetail> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMyGroupDetailUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] detail in
                self?.isLeader = detail.isLeader
                self?.groupTitle = detail.groupName
                self?.groupImageUrl = detail.groupImageUrl
                self?.tag = detail.groupTags.map { $0.name }
                self?.memberCount = detail.memberCount
                self?.limitCount = detail.limitCount
                self?.onlineCount = detail.onlineCount
                self?.leaderName = detail.leaderName
                self?.notice = detail.notice
                self?.isOnline.onNext(detail.isOnline)
                self?.didFetchInfo.onNext(())
                if self?.mode == .notice {
                    self?.didFetchNotice.onNext(())
                }
            })
            .disposed(by: bag)
    }
    
    func fetchMemberList() {
        guard let groupId else { return }
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[MyMember]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMyGroupMemberListUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.memberList = list
                
                if self?.mode == .notice {
                    self?.didFetchMember.onNext(())
                }
            })
            .disposed(by: bag)
    }
    
    func createCalendar(date: Date) {
        updateCurrentDate(date: date)
        mainDayList = createMonthlyCalendarUseCase.execute(date: date)

        let startDate = mainDayList.first?.date ?? Date()
        let endDate = mainDayList.last?.date ?? Date()
        fetchTodo(from: startDate, to: endDate)
    }
    
    func updateCurrentDate(date: Date) {
        currentDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        self.currentDateText = dateFormatter.string(from: date)
    }
    
    func fetchTodo(from: Date, to: Date) {
        guard let groupId else { return }
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Date: [SocialTodoSummary]]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMyGroupCalendarUseCase
                    .execute(token: token, groupId: groupId, from: from, to: to)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] todoDict in
                guard let self else { return }
                self.todos = todoDict
                
                if self.mode == .calendar {
                    self.didFetchCalendar.onNext(())
                }
            })
            .disposed(by: bag)
        
    }
    
    func fetchImage(key: String) -> Single<Data> {
        fetchImageUseCase
            .execute(key: key)
    }
    
    func flipOnlineState() {
        guard let groupId else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.setOnlineUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onFailure: { [weak self] _ in
                self?.isOnline.onNext(try? self?.isOnline.value())
            })
            .disposed(by: bag)
    }
    
    func withdrawGroup() {
        guard let groupId else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.withdrawGroupUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.actions?.pop?()
            }, onError: {
                print($0)
            })
            .disposed(by: bag)
    }
}

//
//  MyGroupDetailViewModel2.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/22.
//

import Foundation
import RxSwift

enum MyGroupDetailMode: Int { //일케하면 데드락 생길수도 있음. 로딩을 분리? 아니면 아에 fetch 메서드를 다르게 가져갈까?
    // 이걸로 구분하면 0눌렀을때 로딩중 바뀌고 fetch 시작, 다되기 전에 1눌러서 fetch 시작, 그럼 1결과를 보여주기 전에 0을 먼저 보여줄 수 있음.
    case notice = 0
    case calendar
    case chat
}
//
//enum MyGroupDetailLoadingState {
//    case notice
//    case calendar
//}

enum MyGroupSecionType {
    case info
    case notice
    case member
    case calendar
    case chat
}

class MyGroupDetailViewModel2 {
    let bag = DisposeBag()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didTappedModeBtnAt: Observable<Int>
        var onlineStateChanged: Observable<Bool>
        
    }
    
    struct Output {
        var showMessage: Observable<Message>
        var didFetchSection: Observable<MyGroupSecionType?>
        var nowLoadingWithBefore: Observable<MyGroupDetailMode?>
    }
    var nowLoadingWithBefore = BehaviorSubject<MyGroupDetailMode?>(value: nil)
    
    var groupId: Int?
    var groupTitle: String?
    var groupImageUrl: String?
    var tag: [String]?
    var memberCount: Int?
    var limitCount: Int?
    var leaderName: String?
    var isLeader: Bool?
    
    var onlineCount = BehaviorSubject<Int?>(value: nil)
    
    var isOnline = BehaviorSubject<Bool?>(value: nil)
    
    // MARK: mode 0, notice section
    var notice: String?
    var memberList: [MyMember]?
    var memberKickedOutAt = PublishSubject<Int>()
    var needReloadMemberAt = PublishSubject<Int>()
    
    var didFetchedSection = BehaviorSubject<MyGroupSecionType?>(value: nil)
    
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
    
    var mode: MyGroupDetailMode?
    
    let showMessage = PublishSubject<Message>()
    
    
    
    
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
        updateGroupCategoryUseCase: UpdateGroupCategoryUseCase
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
    }
    
    func transform(input: Input) -> Output {
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let groupId = vm.groupId else { return }
                vm.mode = .notice
                vm.nowLoadingWithBefore.onNext(vm.mode)
                vm.fetchGroupDetail(groupId: groupId, fetchType: .initail)
                vm.fetchMemberList()
            })
            .disposed(by: bag)

        input
            .didTappedModeBtnAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                let mode = MyGroupDetailMode(rawValue: index)
                switch mode {
                case .notice:
                    
                    if vm.memberList?.isEmpty ?? true {
                        vm.nowLoadingWithBefore.onNext(vm.mode)
                        vm.mode = .notice
                        vm.fetchMemberList()
                    } else {
                        vm.mode = .notice
                        vm.didFetchedSection.onNext(.notice)
                        
                    }
                case .calendar:
                    
                    if vm.mainDayList.isEmpty {
                        vm.nowLoadingWithBefore.onNext(mode)
                        let components = Calendar.current.dateComponents(
                            [.year, .month],
                            from: Date()
                        )
                        
                        let currentDate = Calendar.current.date(from: components) ?? Date()
                        vm.mode = .calendar
                        vm.createCalendar(date: currentDate)
                    } else {
                        vm.mode = .calendar
                        vm.didFetchedSection.onNext(.calendar)
                    }
                case .none:
                    break
                default: break
                }
            })
            .disposed(by: bag)
                    
                    
        
        
        
        input
            .onlineStateChanged
            .withUnretained(self)
            .subscribe(onNext: { vm, isOnline in
                guard let currentState = try? vm.isOnline.value(),
                   currentState != isOnline else { return }
                vm.setOnlineState(isOnline: isOnline)
            })
            .disposed(by: bag)
        

        
        return Output(showMessage: showMessage.asObservable(), didFetchSection: didFetchedSection.asObservable(), nowLoadingWithBefore: nowLoadingWithBefore.asObservable())
    }
    
    
    
    
    
    func bindUseCase() {
        setOnlineUseCase
            .didChangeOnlineState
            .withUnretained(self)
            .subscribe(onNext: { vm, arg in
                let (groupId, memberId) = arg
                if groupId == vm.groupId {
                    guard let exValue = try? vm.isOnline.value(),
                          let onlineCount = try? vm.onlineCount.value() else { return }
                    let newValue = !exValue
                    vm.isOnline.onNext(newValue)
                    vm.onlineCount.onNext(newValue ? (onlineCount + 1) : (onlineCount - 1))
                    
                    guard let index = vm.memberList?.firstIndex(where: { $0.memberId == memberId }),
                          var member = vm.memberList?[index] else { return }
                    
                    member.isOnline = !member.isOnline
                    vm.memberList?[index] = member
                    vm.needReloadMemberAt.onNext(index)
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
                vm.didFetchedSection.onNext(.notice)
                vm.showMessage.onNext(Message(text: "공지사항을 업데이트 하였습니다.", state: .normal))
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
        
        createGroupTodoUseCase //삽입하고 리로드 or 다시 받기.. 뭐가 좋을랑가 -> 걍 다시받자!
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
            .subscribe(onNext: { [weak self] (groupId, memberId) in
                guard let currentGroupId = self?.groupId,
                      groupId == currentGroupId,
                      let index = self?.memberList?.firstIndex(where: { $0.memberId == memberId }) else { return }
                self?.memberList?.remove(at: index)
                self?.memberKickedOutAt.onNext(index)
            })
            .disposed(by: bag)
        
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
                self?.onlineCount.onNext(detail.onlineCount)
                self?.leaderName = detail.leaderName
                self?.notice = detail.notice
                self?.isOnline.onNext(detail.isOnline)
                if self?.mode == .notice {
                    self?.didFetchedSection.onNext(.info)
                    self?.didFetchedSection.onNext(.notice)
                }
            })
            .disposed(by: bag) //.map { "#\($0.name)" }.joined(separator: " ")
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
                    self?.didFetchedSection.onNext(.member)
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
                    self.didFetchedSection.onNext(.calendar)
                }
            })
            .disposed(by: bag)
        
    }
    
    func fetchImage(key: String) -> Single<Data> {
        fetchImageUseCase
            .execute(key: key)
    }
    
    func setOnlineState(isOnline: Bool) {
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
            .subscribe(onError: { [weak self] _ in
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
//                self?.actions?.pop?()
            }, onError: {
                print($0)
            })
            .disposed(by: bag)
    }
}

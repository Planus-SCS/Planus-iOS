//
//  MyGroupDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/22.
//

import Foundation
import RxSwift

enum MyGroupDetailNavigatorType: Int, CaseIterable {
    case dot = 0
    case notice
    case calendar
}

enum MyGroupSecionType {
    case info
    case notice
    case member
    case calendar
    case chat
}

final class MyGroupDetailViewModel: ViewModel {
    
    struct UseCases {
        let fetchMyGroupDetailUseCase: FetchMyGroupDetailUseCase
        let updateNoticeUseCase: UpdateNoticeUseCase
        let updateInfoUseCase: UpdateGroupInfoUseCase
        let withdrawGroupUseCase: WithdrawGroupUseCase
        
        let fetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase
        let fetchImageUseCase: FetchImageUseCase
        let memberKickOutUseCase: MemberKickOutUseCase
        let setOnlineUseCase: SetOnlineUseCase
        
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        
        let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
        let fetchMyGroupCalendarUseCase: FetchGroupMonthlyCalendarUseCase
        
        let createGroupTodoUseCase: CreateGroupTodoUseCase
        let updateGroupTodoUseCase: UpdateGroupTodoUseCase
        let deleteGroupTodoUseCase: DeleteGroupTodoUseCase
        let updateGroupCategoryUseCase: UpdateGroupCategoryUseCase
        
        let generateGroupLinkUseCase: GenerateGroupLinkUseCase
    }
    
    struct Actions {
        let showDailyCalendar: ((SocialDailyCalendarViewModel.Args) -> Void)?
        let showMemberProfile: ((MemberProfileViewModel.Args) -> Void)?
        let editInfo: ((MyGroupInfoEditViewModel.Args) -> Void)?
        let editMember: ((MyGroupMemberEditViewModel.Args) -> Void)?
        let editNotice: ((MyGroupNoticeEditViewModel.Args) -> Void)?
        let pop: (() -> Void)?
        let finishScene: (() -> Void)?
    }
    
    struct Args {
        let groupId: Int
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    
    let bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didTappedModeBtnAt: Observable<Int>
        var didChangedMonth: Observable<Date>
        var didSelectedDayAt: Observable<Int>
        var didSelectedMemberAt: Observable<Int>
        var didTappedOnlineButton: Observable<Void>
        var didTappedShareBtn: Observable<Void>
        var didTappedInfoEditBtn: Observable<Void>
        var didTappedMemberEditBtn: Observable<Void>
        var didTappedNoticeEditBtn: Observable<Void>
        var backBtnTapped: Observable<Void>
    }
    
    struct Output {
        var showMessage: Observable<Message>
        var didInitialFetch: Observable<Void>
        var didFetchInfo: Observable<Void?>
        var didFetchNotice: Observable<Void?>
        var didFetchMember: Observable<Void?>
        var didFetchCalendar: Observable<Void?>
        var nowLoadingWithBefore: Observable<MyGroupDetailPageType?>
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
    
    let groupId: Int
    
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
    var memberList: [MyGroupMemberProfile]?
    var memberKickedOutAt = PublishSubject<Int>()
    var needReloadMemberAt = PublishSubject<Int>()
    
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
    var mainDays = [Day]()
    var todos = [Date: [SocialTodoSummary]]()
    
    var todoStackingCache = [[Bool]](repeating: [Bool](repeating: false, count: 20), count: 42) //투두 스택쌓는 용도, 블럭 사이에 자리 있는지 확인하는 애
    var weekDayChecker = [Int](repeating: -1, count: 6) //firstDayOfWeekChecker
    var todosInDayViewModels = [SocialTodosInDayViewModel](repeating: SocialTodosInDayViewModel(), count: 42) //UI 표시용 뷰모델
    var cachedCellHeightForTodoCount = [Int: Double]()
    
    var showDaily = PublishSubject<Date>()
    
    var mode: MyGroupDetailPageType?
    
    let showMessage = PublishSubject<Message>()
    let modeChanged = PublishSubject<Void>()
    
    
    lazy var membersFetcher: (Int) -> Single<[MyGroupMemberProfile]>? = { [weak self] groupId in
        guard let self else { return nil }
        return self.useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.fetchMyGroupMemberListUseCase
                    .execute(token: token, groupId: groupId)
            }
    }
    
    lazy var groupDetailFetcher: (Int) -> Single<MyGroupDetail>? = { [weak self] groupId in
        guard let self else { return nil }
        return self.useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.fetchMyGroupDetailUseCase
                    .execute(token: token, groupId: groupId)
            }
    }
    
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.groupId = injectable.args.groupId
    }
    
    func transform(input: Input) -> Output {
        
        bindUseCase()
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.mode = .notice
                vm.nowInitLoading.onNext(())
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    vm.initFetchDetails(groupId: vm.groupId)
                })
            })
            .disposed(by: bag)
        
        input
            .didTappedModeBtnAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.changeMode(to: index)
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
                guard let groupTitle = vm.groupTitle,
                      let member = vm.memberList?[index] else { return }
                
                vm.actions.showMemberProfile?(
                    MemberProfileViewModel.Args(
                        group: GroupName(groupId: vm.groupId, groupName: groupTitle),
                        member: member
                    )
                )
            })
            .disposed(by: bag)
        
        input
            .didSelectedDayAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.actions.showDailyCalendar?(
                    SocialDailyCalendarViewModel.Args(
                        group: GroupName(groupId: vm.groupId, groupName: vm.groupTitle ?? String()),
                        type: .group(isLeader: vm.isLeader ?? Bool()),
                        date: vm.mainDays[index].date
                    )
                )
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
            .didTappedShareBtn
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                let urlString = vm.generateShareLink()
                vm.showShareMenu.onNext(urlString)
            })
            .disposed(by: bag)
        
        input
            .didTappedInfoEditBtn
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.editInfo?(
                    MyGroupInfoEditViewModel.Args(
                        id: vm.groupId,
                        title: vm.groupTitle ?? String(),
                        imageUrl: vm.groupImageUrl ?? String(),
                        tagList: vm.tag ?? [String](),
                        maxMember: vm.limitCount ?? Int()
                    )
                )
            })
            .disposed(by: bag)
        
        input
            .didTappedNoticeEditBtn
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.editNotice?(
                    MyGroupNoticeEditViewModel.Args(
                        groupId: vm.groupId,
                        notice: vm.notice ?? String()
                    )
                )
            })
            .disposed(by: bag)
        
        input
            .didTappedMemberEditBtn
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.editMember?(MyGroupMemberEditViewModel.Args(groupId: vm.groupId))
            })
            .disposed(by: bag)
        
        input
            .backBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.pop?()
            })
            .disposed(by: bag)
        
        let initFetched = Observable.zip(
            didFetchInfo.compactMap { $0 },
            didFetchNotice.compactMap { $0 },
            didFetchMember.compactMap { $0 }
        ).map { _ in () }
        
        return Output(
            showMessage: showMessage.asObservable(),
            didInitialFetch: initFetched,
            didFetchInfo: didFetchInfo.asObservable(),
            didFetchNotice: didFetchNotice.asObservable(),
            didFetchMember: didFetchMember.asObservable(),
            didFetchCalendar: didFetchCalendar.asObservable(),
            nowLoadingWithBefore: nowLoadingWithBefore.asObservable(),
            memberKickedOutAt: memberKickedOutAt.asObservable(),
            needReloadMemberAt: needReloadMemberAt.asObservable(),
            onlineStateChanged: isOnline.asObservable(),
            modeChanged: modeChanged.asObservable(),
            showShareMenu: showShareMenu.asObservable(),
            nowInitLoading: nowInitLoading.asObservable()
        )
    }
}

// MARK: - Mode Actions
private extension MyGroupDetailViewModel {
    func changeMode(to index: Int) {
        let mode = MyGroupDetailPageType(rawValue: index)
        self.mode = mode
        self.modeChanged.onNext(())
        switch mode {
        case .notice:
            if memberList?.isEmpty ?? true {
                nowLoadingWithBefore.onNext(mode)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                    guard let self else { return }
                    fetchMemberList(groupId: groupId)
                })
            } else {
                self.mode = .notice
                didFetchNotice.onNext(())
            }
        case .calendar:
            if mainDays.isEmpty {
                nowLoadingWithBefore.onNext(mode)
                let components = Calendar.current.dateComponents(
                    [.year, .month],
                    from: Date()
                )
                
                let currentDate = Calendar.current.date(from: components) ?? Date()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                    self?.createCalendar(date: currentDate)
                })
                
            } else {
                didFetchCalendar.onNext(())
            }
        default: return
        }
    }
}

private extension MyGroupDetailViewModel {
    func generateShareLink() -> String? {
        return useCases.generateGroupLinkUseCase.execute(groupId: groupId)
    }
}

// MARK: - bind UseCases
private extension MyGroupDetailViewModel {
    func bindUseCase() {
        useCases
            .setOnlineUseCase
            .didChangeOnlineState
            .withUnretained(self)
            .subscribe(onNext: { vm, arg in
                let (groupId, memberId) = arg
                guard groupId == vm.groupId else { return }
                vm.changeOnlineState(memberId: memberId)
            })
            .disposed(by: bag)
        
        useCases
            .updateNoticeUseCase
            .didUpdateNotice
            .withUnretained(self)
            .subscribe(onNext: { vm, groupNotice in
                guard vm.groupId == groupNotice.groupId else { return }
                vm.notice = groupNotice.notice
                if vm.mode == .notice {
                    vm.didFetchNotice.onNext(())
                    vm.showMessage.onNext(Message(text: "공지사항을 업데이트 하였습니다.", state: .normal))
                }
            })
            .disposed(by: bag)
        
        useCases
            .updateInfoUseCase
            .didUpdateInfoWithId
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                guard id == vm.groupId else { return }
                vm.fetchGroupDetail(groupId: id)
            })
            .disposed(by: bag)
        
        useCases
            .createGroupTodoUseCase
            .didCreateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.groupId == todo.groupId else { return }
                let startDate = vm.mainDays.first?.date ?? Date()
                let endDate = vm.mainDays.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        useCases
            .updateGroupTodoUseCase
            .didUpdateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.groupId == todo.groupId else { return }
                let startDate = vm.mainDays.first?.date ?? Date()
                let endDate = vm.mainDays.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        useCases
            .deleteGroupTodoUseCase
            .didDeleteGroupTodoWithIds
            .withUnretained(self)
            .subscribe(onNext: { vm, ids in
                guard vm.groupId == ids.groupId else { return }
                let startDate = vm.mainDays.first?.date ?? Date()
                let endDate = vm.mainDays.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        useCases
            .updateGroupCategoryUseCase
            .didUpdateCategoryWithGroupId
            .withUnretained(self)
            .subscribe(onNext: { vm, categoryWithGroupId in
                guard vm.groupId == categoryWithGroupId.groupId else { return }
                let startDate = vm.mainDays.first?.date ?? Date()
                let endDate = vm.mainDays.last?.date ?? Date()
                vm.fetchTodo(from: startDate, to: endDate)
            })
            .disposed(by: bag)
        
        useCases
            .memberKickOutUseCase
            .didKickOutMemberAt
            .withUnretained(self)
            .subscribe(onNext: { vm, args in
                let (groupId, memberId) = args
                guard groupId == vm.groupId,
                      let index = vm.memberList?.firstIndex(where: { $0.memberId == memberId }) else { return }
                vm.memberList?.remove(at: index)
                if vm.mode == .notice {
                    vm.memberKickedOutAt.onNext(index)
                }
            })
            .disposed(by: bag)
        
    }
}

private extension MyGroupDetailViewModel {
    func changeOnlineState(memberId: Int) {
        guard let exValue = try? isOnline.value(),
              let onlineCount else { return }
        let newValue = !exValue
        
        self.onlineCount = newValue ? (onlineCount + 1) : (onlineCount - 1)
        isOnline.onNext(newValue)
        
        showMessage.onNext(Message(text: "\(groupTitle ?? "") 그룹을 \(newValue ? "온" : "오프")라인으로 전환하였습니다.", state: .normal))
        guard let index = memberList?.firstIndex(where: { $0.memberId == memberId }),
              var member = memberList?[index] else { return }
        
        member.isOnline = !member.isOnline
        memberList?[index] = member
        
        if mode == .notice {
            needReloadMemberAt.onNext(index)
        }
        
    }
}

private extension MyGroupDetailViewModel {
    func setGroupDetail(detail: MyGroupDetail) {
        self.isLeader = detail.isLeader
        self.groupTitle = detail.groupName
        self.groupImageUrl = detail.groupImageUrl
        self.tag = detail.groupTags.map { $0.name }
        self.memberCount = detail.memberCount
        self.limitCount = detail.limitCount
        self.onlineCount = detail.onlineCount
        self.leaderName = detail.leaderName
        self.notice = detail.notice
        self.isOnline.onNext(detail.isOnline)
    }
}

// MARK: - api
private extension MyGroupDetailViewModel {
    func initFetchDetails(groupId: Int) {
        let groupDetailFetcher = useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.fetchMyGroupDetailUseCase
                    .execute(token: token, groupId: groupId)
            }
        
        let membersFetcher = useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.fetchMyGroupMemberListUseCase
                    .execute(token: token, groupId: groupId)
            }
        
        Single.zip(
            groupDetailFetcher,
            membersFetcher
        )
        .subscribe(onSuccess: { [weak self] (detail, members) in
            self?.setGroupDetail(detail: detail)
            self?.memberList = members
            
            self?.didFetchInfo.onNext(())
            if self?.mode == .notice {
                self?.didFetchNotice.onNext(())
                self?.didFetchMember.onNext(())
            }
        })
        .disposed(by: bag)
    }
    
    func fetchGroupDetail(groupId: Int) {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.fetchMyGroupDetailUseCase
                    .execute(token: token, groupId: groupId)
            }
            .subscribe(onSuccess: { [weak self] detail in
                self?.setGroupDetail(detail: detail)
                self?.didFetchInfo.onNext(())
                if self?.mode == .notice {
                    self?.didFetchNotice.onNext(())
                }
            })
            .disposed(by: bag)
    }
    
    func fetchMemberList(groupId: Int) {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.fetchMyGroupMemberListUseCase
                    .execute(token: token, groupId: groupId)
            }
            .subscribe(onSuccess: { [weak self] list in
                self?.memberList = list
                
                if self?.mode == .notice {
                    self?.didFetchMember.onNext(())
                }
            })
            .disposed(by: bag)
    }
    
    func fetchTodo(from: Date, to: Date) {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token -> Single<[Date: [SocialTodoSummary]]>? in
                guard let self else { return nil }
                return self.useCases.fetchMyGroupCalendarUseCase
                    .execute(token: token, groupId: self.groupId, from: from, to: to)
            }
            .subscribe(onSuccess: { [weak self] todoDict in
                guard let self else { return }
                self.todos = todoDict
                
                if self.mode == .calendar {
                    self.didFetchCalendar.onNext(())
                }
            })
            .disposed(by: bag)
        
    }
}

// MARK: Image Fetcher
extension MyGroupDetailViewModel {
    func fetchImage(key: String) -> Single<Data> {
        useCases
            .fetchImageUseCase
            .execute(key: key)
    }
    
    func withdrawGroup() {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token -> Single<Void>? in
                guard let self else { return nil }
                return self.useCases.withdrawGroupUseCase
                    .execute(token: token, groupId: self.groupId)
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.actions.pop?()
            }, onError: {
                print($0)
            })
            .disposed(by: bag)
    }
}

// MARK: Calendar
private extension MyGroupDetailViewModel {
    func createCalendar(date: Date) {
        updateCurrentDate(date: date)
        mainDays = useCases.createMonthlyCalendarUseCase.execute(date: date)

        let startDate = mainDays.first?.date ?? Date()
        let endDate = mainDays.last?.date ?? Date()
        fetchTodo(from: startDate, to: endDate)
    }
    
    func updateCurrentDate(date: Date) {
        currentDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        self.currentDateText = dateFormatter.string(from: date)
    }
}

// MARK: Online Actions
extension MyGroupDetailViewModel {
    func flipOnlineState() {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token -> Single<Void>? in
                guard let self else { return nil }
                return self.useCases.setOnlineUseCase
                    .execute(token: token, groupId: self.groupId)
            }
            .subscribe(onFailure: { [weak self] _ in
                self?.isOnline.onNext(try? self?.isOnline.value())
            })
            .disposed(by: bag)
    }
}

// MARK: VC쪽이 UI용 투두 ViewModel 준비를 위해 요청
extension MyGroupDetailViewModel {
    func stackTodosInDayViewModelOfWeek(at indexPath: IndexPath) {
        let date = mainDays[indexPath.item].date
        if indexPath.item%7 == 0, //월요일만 진입 가능
           weekDayChecker[indexPath.item/7] != sharedCalendar.component(.weekOfYear, from: date) {
            weekDayChecker[indexPath.item/7] = sharedCalendar.component(.weekOfYear, from: date)
            (indexPath.item..<indexPath.item + 7).forEach { //해당주차의 todoStackingCache를 전부 0으로 초기화
                todoStackingCache[$0] = [Bool](repeating: false, count: 20)
            }
            
            for (item, day) in Array(mainDays.enumerated())[indexPath.item..<indexPath.item + 7] {
                var todoList = todos[day.date] ?? []
                
                let singleTodoList = prepareSingleTodosInDay(at: IndexPath(item: item, section: indexPath.section), todos: todoList)
                let periodTodoList = preparePeriodTodosInDay(at: IndexPath(item: item, section: indexPath.section), todos: todoList)
                
                todosInDayViewModels[item] = generateTodosInDayViewModel(
                    at: IndexPath(item: item, section: indexPath.section),
                    singleTodos: singleTodoList,
                    periodTodos: periodTodoList
                )
            }
        }
    }
    
    func maxHeightTodosInDayViewModelOfWeek(at indexPath: IndexPath) -> SocialTodosInDayViewModel? {
        let weekRange = (indexPath.item - indexPath.item%7..<indexPath.item - indexPath.item%7 + 7)
        
        return todosInDayViewModels[weekRange]
            .max(by: { a, b in
                let aHeight = (a.holiday != nil) ? a.holiday!.0 : (a.singleTodo.last != nil) ?
                a.singleTodo.last!.0 : (a.periodTodo.last != nil) ? a.periodTodo.last!.0 : 0
                let bHeight = (b.holiday != nil) ? b.holiday!.0 : (b.singleTodo.last != nil) ?
                b.singleTodo.last!.0 : (b.periodTodo.last != nil) ? b.periodTodo.last!.0 : 0
                return aHeight < bHeight
            })
    }
}

// MARK: prepare TodosInDayViewModel
private extension MyGroupDetailViewModel {
    func generateTodosInDayViewModel(at indexPath: IndexPath, singleTodos: [SocialTodoSummary], periodTodos: [SocialTodoSummary]) -> SocialTodosInDayViewModel {
        let filteredPeriodTodos: [(Int, SocialTodoSummary)] = periodTodos.compactMap { todo in
            for i in (0..<todoStackingCache[indexPath.item].count) {
                if todoStackingCache[indexPath.item][i] == false,
                   let period = sharedCalendar.dateComponents([.day], from: todo.startDate, to: todo.endDate).day {
                    for j in (0...period) {
                        todoStackingCache[indexPath.item+j][i] = true
                    }
                    return (i, todo)
                }
            }
            return nil
        }

        let singleTodoInitialIndex = todoStackingCache[indexPath.item].enumerated().first(where: { _, isFilled in
            return isFilled == false
        })?.offset ?? 0
        
        let filteredSingleTodos = singleTodos.enumerated().map { (index, todo) in
            return (index + singleTodoInitialIndex, todo)
        }
        
        var holiday: (Int, String)?
        if let holidayTitle = HolidayPool.shared.holidays[mainDays[indexPath.item].date] {
            let holidayIndex = singleTodoInitialIndex + singleTodos.count
            holiday = (holidayIndex, holidayTitle)
        }
        
        return SocialTodosInDayViewModel(periodTodo: filteredPeriodTodos, singleTodo: filteredSingleTodos, holiday: holiday)
    }
    
    func prepareSingleTodosInDay(at indexPath: IndexPath, todos: [SocialTodoSummary]) -> [SocialTodoSummary] {
        return todos.filter { $0.startDate == $0.endDate }
    }
    
    func preparePeriodTodosInDay(at indexPath: IndexPath, todos: [SocialTodoSummary]) -> [SocialTodoSummary] {
        var periodList = todos.filter { $0.startDate != $0.endDate }
        let date = mainDays[indexPath.item].date
        
        if indexPath.item % 7 != 0 { // 만약 월요일이 아닐 경우, 오늘 시작하는것들만
            periodList = periodList.filter { $0.startDate == date }
                .sorted { $0.endDate < $1.endDate }
        } else { //월요일 중에 오늘이 startDate가 아닌 놈들만 startDate로 정렬, 그 뒤에는 전부다 endDate로 정렬하고, 이걸 다시 endDate를 업데이트
            let continuousPeriodList = periodList
                .filter { $0.startDate != date }
                .sorted{ ($0.startDate == $1.startDate) ? $0.endDate < $1.endDate : $0.startDate < $1.startDate }
                .map { todo in
                    var tmpTodo = todo
                    tmpTodo.startDate = date
                    return tmpTodo
                }
            
            let initialPeriodList = periodList
                .filter { $0.startDate == date }
                .sorted{ $0.endDate < $1.endDate }
            
            periodList = continuousPeriodList + initialPeriodList
        }
        
        let firstDayOfWeek = sharedCalendar.date(from: sharedCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))
        let lastDayOfWeek = sharedCalendar.date(byAdding: .day, value: 6, to: firstDayOfWeek!)!  //일요일임.
        
        return periodList.map { todo in
            let currentWeek = sharedCalendar.component(.weekOfYear, from: date)
            let endWeek = sharedCalendar.component(.weekOfYear, from: todo.endDate)
            
            if currentWeek != endWeek {
                var tmpTodo = todo
                tmpTodo.endDate = lastDayOfWeek
                return tmpTodo
            } else {
                return todo
            }
        }
    }
}

//
//  MemberProfileViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import Foundation
import RxSwift

final class MemberProfileViewModel: ViewModel {
    
    struct UseCases {
        let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
        let dateFormatYYYYMMUseCase: DateFormatYYYYMMUseCase
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        let fetchMemberCalendarUseCase: FetchGroupMemberCalendarUseCase
        let fetchImageUseCase: FetchImageUseCase
    }
    
    struct Actions {
        let showSocialDailyCalendar: ((SocialDailyCalendarViewModel.Args) -> Void)?
        let pop: (() -> Void)?
        let finishScene: (() -> Void)?
    }
    
    struct Args {
        let group: GroupName
        let member: MyGroupMemberProfile
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    var bag = DisposeBag()
    let useCases: UseCases
    let actions: Actions
    
    let calendar = Calendar.current
    
    let group: GroupName
    let member: MyGroupMemberProfile
    
    // for todoList caching
    let cachingIndexDiff = 8
    let cachingAmount = 10
    
    let endOfFirstIndex = -24
    let endOfLastIndex = 24
    
    var latestPrevCacheRequestedIndex = 0
    var latestFollowingCacheRequestedIndex = 0
    
    var today: Date = {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    var currentDate = BehaviorSubject<Date?>(value: nil)
    var currentYYYYMM = BehaviorSubject<String?>(value: nil)
    
    var mainDays = [[Day]]()
    var todos = [Date: [SocialTodoSummary]]()
    
    var todoStackingCache = [[Bool]](repeating: [Bool](repeating: false, count: 20), count: 42) //투두 스택쌓는 용도, 블럭 사이에 자리 있는지 확인하는 애
    var weekDayChecker = [Int](repeating: -1, count: 6) //firstDayOfWeekChecker
    var todosInDayViewModels = [SocialTodosInDayViewModel](repeating: SocialTodosInDayViewModel(), count: 42) //UI 표시용 뷰모델
    var cachedCellHeightForTodoCount = [Int: Double]()
    
    var initialDayListFetchedInCenterIndex = BehaviorSubject<Int?>(value: nil)
    var categoryFetched = BehaviorSubject<Void?>(value: nil)
    var needReloadSection = BehaviorSubject<IndexSet?>(value: nil)
    var profileImage = BehaviorSubject<Data?>(value: nil)
    
    var showMonthPicker = PublishSubject<(Date, Date, Date)>()
    var didSelectMonth = PublishSubject<Int>()
    
    var currentIndex = Int()
    
    struct Input {
        var indexChanged: Observable<Int>
        var viewDidLoaded: Observable<Void>
        var didSelectItem: Observable<IndexPath>
        var didTappedTitleButton: Observable<Void>
        var didSelectMonth: Observable<Date>
        var backBtnTapped: Observable<Void>
    }
    
    struct Output {
        var didLoadYYYYMM: Observable<String?>
        var initialDayListFetchedInCenterIndex: Observable<Int?>
        var needReloadSectionInRange: Observable<IndexSet?> // a부터 b까지 리로드 해라!
        var showMonthPicker: Observable<(Date, Date, Date)> //앞 현재 끝
        var monthChangedByPicker: Observable<Int> //인덱스만 알려주자!
        var memberName: String?
        var memberDesc: String?
        var memberImage: Observable<Data?>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.group = injectable.args.group
        self.member = injectable.args.member
    }
    
    func bind() {
        currentDate
            .compactMap { $0 }
            .subscribe { [weak self] date in
                self?.updateTitle(date: date)
            }
            .disposed(by: bag)
        
        // init
        currentDate
            .compactMap { $0 }
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { vm, date in
                vm.initCalendar(date: date)
                vm.initTodoList(date: date)
            })
            .disposed(by: bag)
    }
    
    func transform(input: Input) -> Output {
        bind()
        
        input.viewDidLoaded
            .withUnretained(self)
            .subscribe { vm, _ in
                let components = vm.calendar.dateComponents(
                    [.year, .month],
                    from: Date()
                )
                let currentDate = vm.calendar.date(from: components) ?? Date()
                vm.currentDate.onNext(currentDate)
            }
            .disposed(by: bag)
        
        input
            .indexChanged
            .withUnretained(self)
            .subscribe { vm, index in
                vm.scrolledTo(index: index)
            }
            .disposed(by: bag)
        
        input
            .didSelectItem
            .withUnretained(self)
            .subscribe { vm, indexPath in
                vm.actions.showSocialDailyCalendar?(
                    SocialDailyCalendarViewModel.Args(
                        group: vm.group,
                        type: .member(id: vm.member.memberId),
                        date: vm.mainDays[indexPath.section][indexPath.item].date
                    )
                )
            }
            .disposed(by: bag)
        
        input
            .didTappedTitleButton
            .withUnretained(self)
            .subscribe { vm, _ in
                guard let currentDate = try? vm.currentDate.value() else { return }
                let first = vm.mainDays[0][7].date
                let last = vm.mainDays[vm.mainDays.count-1][7].date
                vm.showMonthPicker.onNext((first, currentDate, last))
            }
            .disposed(by: bag)
        
        input.didSelectMonth
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vm, date in
                let start = vm.mainDays[0][7].date
                let index = vm.calendar.dateComponents([.month], from: vm.calendar.startDayOfMonth(date: start), to: date).month ?? 0
                vm.currentIndex = index
                vm.currentDate.onNext(date)
                vm.didSelectMonth.onNext(index)
                vm.initTodoList(date: date)
            })
            .disposed(by: bag)
        
        input
            .backBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.pop?()
            })
            .disposed(by: bag)
        
        if let url = member.profileImageUrl {
            fetchImage(key: url)
                .subscribe(onSuccess: { [weak self] data in
                    self?.profileImage.onNext(data)
                })
                .disposed(by: bag)
        }
        
        return Output(
            didLoadYYYYMM: currentYYYYMM.asObservable(),
            initialDayListFetchedInCenterIndex: initialDayListFetchedInCenterIndex.asObservable(),
            needReloadSectionInRange: needReloadSection.asObservable(),
            showMonthPicker: showMonthPicker.asObservable(),
            monthChangedByPicker: didSelectMonth.asObservable(),
            memberName: member.nickname,
            memberDesc: member.description,
            memberImage: profileImage.asObservable()
        )
    }
}

// MARK: - calendar
private extension MemberProfileViewModel {
    func updateTitle(date: Date) {
        currentYYYYMM.onNext(useCases.dateFormatYYYYMMUseCase.execute(date: date))
    }
    
    func initCalendar(date: Date) {
        mainDays = (endOfFirstIndex...endOfLastIndex).map { difference -> [Day] in
            let calendarDate = self.calendar.date(byAdding: DateComponents(month: difference), to: date) ?? Date()
            return useCases.createMonthlyCalendarUseCase.execute(date: calendarDate)
        }
        currentIndex = -endOfFirstIndex
        latestPrevCacheRequestedIndex = currentIndex
        latestFollowingCacheRequestedIndex = currentIndex
        
        initialDayListFetchedInCenterIndex.onNext(currentIndex)
    }
    
    func initTodoList(date: Date) {
        let fromIndex = (currentIndex - cachingAmount >= 0) ? currentIndex - cachingAmount : 0
        let toIndex = currentIndex + cachingAmount + 1 < mainDays.count ? currentIndex + cachingAmount + 1 : mainDays.count-1
        
        fetchTodoList(from: fromIndex, to: toIndex)
    }

    func scrolledTo(index: Int) {
        let indexBefore = currentIndex
        currentIndex = index
        
        updateCurrentDate(direction: (indexBefore == index) ? .none : (indexBefore > index) ? .left : .right)
        checkCacheLoadNeed()
    }
    
    func updateCurrentDate(direction: ScrollDirection) {
        guard let previousDate = try? self.currentDate.value() else { return }
        switch direction {
        case .left:
            currentDate.onNext(self.calendar.date(
                                byAdding: DateComponents(month: -1),
                                to: previousDate
                        ))
        case .right:
            currentDate.onNext(self.calendar.date(
                                byAdding: DateComponents(month: 1),
                                to: previousDate
                        ))
        case .none:
            return
        }
    }
    
    func checkCacheLoadNeed() {
        guard let currentDate = try? self.currentDate.value() else { return }
        if latestPrevCacheRequestedIndex - currentIndex == cachingIndexDiff {
            latestPrevCacheRequestedIndex = currentIndex
            let fromIndex = currentIndex - cachingAmount
            let toIndex = currentIndex - (cachingAmount - cachingIndexDiff)
            fetch(from: fromIndex, to: toIndex)
            
        } else if currentIndex - latestFollowingCacheRequestedIndex == cachingIndexDiff {
            latestFollowingCacheRequestedIndex = currentIndex
            let fromIndex = currentIndex + cachingAmount - cachingIndexDiff + 1
            let toIndex = currentIndex + cachingAmount + 1
            fetch(from: fromIndex, to: toIndex)
        }
    }
    
    func fetch(from fromIndex: Int, to toIndex: Int) {
        fetchTodoList(from: fromIndex, to: toIndex)
    }
    
    func fetchTodoList(from fromIndex: Int, to toIndex: Int) {

        guard let currentDate = try? self.currentDate.value() else { return }
        
        let fromMonth = calendar.date(byAdding: DateComponents(month: fromIndex - currentIndex), to: currentDate) ?? Date()
        let toMonth = calendar.date(byAdding: DateComponents(month: toIndex - currentIndex), to: currentDate) ?? Date()
        
        let fromMonthStart = calendar.date(byAdding: DateComponents(day: -7), to: calendar.startOfDay(for: fromMonth)) ?? Date()
        let toMonthStart = calendar.date(byAdding: DateComponents(day: 7), to: calendar.startOfDay(for: toMonth)) ?? Date()

        
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token -> Single<[Date: [SocialTodoSummary]]>? in
                guard let self else { return nil }
                return self.useCases.fetchMemberCalendarUseCase
                    .execute(
                        token: token,
                        groupId: self.group.groupId,
                        memberId: self.member.memberId,
                        from: fromMonthStart,
                        to: toMonthStart
                    )
            }
            .subscribe(onSuccess: { [weak self] todoDict in
                guard let self else { return }
                self.todos.merge(todoDict) { (_, new) in new }
                self.needReloadSection.onNext(IndexSet(fromIndex...toIndex))
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        useCases
            .fetchImageUseCase
            .execute(key: key)
    }
}

// MARK: VC쪽이 UI용 투두 ViewModel 준비를 위해 요청
extension MemberProfileViewModel {
    func stackTodosInDayViewModelOfWeek(at indexPath: IndexPath) {
        let date = mainDays[indexPath.section][indexPath.item].date
        if indexPath.item%7 == 0, //월요일만 진입 가능
           weekDayChecker[indexPath.item/7] != sharedCalendar.component(.weekOfYear, from: date) {
            weekDayChecker[indexPath.item/7] = sharedCalendar.component(.weekOfYear, from: date)
            (indexPath.item..<indexPath.item + 7).forEach { //해당주차의 todoStackingCache를 전부 0으로 초기화
                todoStackingCache[$0] = [Bool](repeating: false, count: 20)
            }
            
            for (item, day) in Array(mainDays[indexPath.section].enumerated())[indexPath.item..<indexPath.item + 7] {
                let todoList = todos[day.date] ?? []
                
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
private extension MemberProfileViewModel {
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

        let singleTodoInitialIndex = (todoStackingCache[indexPath.item].lastIndex(where: { isFilled in
            return isFilled == true
        }) ?? -1) + 1
        
        let filteredSingleTodos = singleTodos.enumerated().map { (index, todo) in
            return (index + singleTodoInitialIndex, todo)
        }
        
        var holiday: (Int, String)?
        if let holidayTitle = HolidayPool.shared.holidays[mainDays[indexPath.section][indexPath.item].date] {
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
        let date = mainDays[indexPath.section][indexPath.item].date
        
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

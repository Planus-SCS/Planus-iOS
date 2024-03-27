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
    
    // MARK: Models
    var mainDays = [[Day]]()
    var todos = [Date: [TodoSummaryViewModel]]()
    
    // MARK: UI Generater, Buffer
    var todoStackingBuffer = [[Bool]](repeating: [Bool](repeating: false, count: 30), count: 42) //투두 스택쌓는 용도, 블럭 사이에 자리 있는지 확인하는 애
    var dailyViewModels = [Date: DailyViewModel]()
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
        var didInitDrawed: Observable<Void>
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
                vm.initCalendar(date: currentDate)
            }
            .disposed(by: bag)
        
        input
            .didInitDrawed
            .withUnretained(self)
            .subscribe { vm, _ in
                guard let currentDate = try? vm.currentDate.value() else { return }
                vm.initTodoList(date: currentDate)
            }
            .disposed(by: bag)
        
        input
            .indexChanged
            .withUnretained(self)
            .subscribe { vm, index in
                print("index changed to \(index)")
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

// MARK: - calendar UI
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
        latestPrevCacheRequestedIndex = currentIndex
        latestFollowingCacheRequestedIndex = currentIndex
        
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
}

// MARK: - api fetcher
extension MemberProfileViewModel {
    func fetch(from fromIndex: Int, to toIndex: Int) {
        fetchTodoList(from: fromIndex, to: toIndex)
    }
    
    func fetchTodoList(from fromIndex: Int, to toIndex: Int) {

        guard let currentDate = try? self.currentDate.value() else { return }
        
        let fromMonth = calendar.date(byAdding: DateComponents(month: fromIndex - currentIndex), to: currentDate) ?? Date()
        let toMonth = calendar.date(byAdding: DateComponents(month: toIndex - currentIndex), to: currentDate) ?? Date()
        
        let fromMonthStart = calendar.date(byAdding: DateComponents(day: -7), to: calendar.startOfDay(for: fromMonth)) ?? Date()
        let toMonthStart = calendar.date(byAdding: DateComponents(day: 7), to: calendar.startOfDay(for: toMonth)) ?? Date()
        print(fromMonthStart, toMonthStart)
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token -> Single<[Date: [TodoSummaryViewModel]]>? in
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
                self.prepareViewModel(indexSet: IndexSet(fromIndex...toIndex))
            })
            .disposed(by: bag)
    }
    
    
    func fetchImage(key: String) -> Single<Data> {
        useCases
            .fetchImageUseCase
            .execute(key: key)
    }
}

extension MemberProfileViewModel {
    func prepareViewModel(indexSet: IndexSet) {
        indexSet.forEach { section in
            (0..<mainDays[section].count).forEach { item in
                if item%7 == 0 {
                    stackDailyViewModelOfWeek(at: IndexPath(item: item, section: section))
                }
            }
        }
        self.needReloadSection.onNext(indexSet)
    }
}

// MARK: VC쪽이 UI용 투두 ViewModel 준비를 위해 요청
extension MemberProfileViewModel {
    func stackDailyViewModelOfWeek(at indexPath: IndexPath) {
        if indexPath.item%7 == 0 {
            (indexPath.item..<indexPath.item + 7).forEach {
                todoStackingBuffer[$0] = [Bool](repeating: false, count: 30)
            }
            
            for (item, day) in Array(mainDays[indexPath.section].enumerated())[indexPath.item..<indexPath.item + 7] {
                let todoList = todos[day.date] ?? []
                let singleTodoList = prepareSingleTodosInDay(at: IndexPath(item: item, section: indexPath.section), todos: todoList)
                let periodTodoList = preparePeriodTodosInDay(at: IndexPath(item: item, section: indexPath.section), todos: todoList)
                
                dailyViewModels[day.date] = generateDailyViewModel(
                    at: IndexPath(item: item, section: indexPath.section),
                    singleTodos: singleTodoList,
                    periodTodos: periodTodoList
                )
            }
        }
    }
    
//    func getDayHeight(at indexPath: IndexPath) -> Int {
//        let date = mainDays[indexPath.section][indexPath.item].date
//        guard let viewModel = dailyViewModels[date] else { return 0 }
//        
//        return viewModel.holiday != nil
//        ? viewModel.holiday!.0 + 1 : viewModel.singleTodo.last != nil
//        ? viewModel.singleTodo.last!.0 + 1 : viewModel.periodTodo.last != nil
//        ? viewModel.periodTodo.last!.0 + 1 : 0
//    }
    
    func getDayHeight(viewModel: DailyViewModel) -> Int {
        return viewModel.holiday != nil
        ? viewModel.holiday!.0 + 1 : viewModel.singleTodo.last != nil
        ? viewModel.singleTodo.last!.0 + 1 : viewModel.periodTodo.last != nil
        ? viewModel.periodTodo.last!.0 + 1 : 0
    }
    
    func largestDailyViewModelOfWeek(at indexPath: IndexPath) -> (Int, DailyViewModel?) {
        let weekRange = (indexPath.item - indexPath.item%7..<indexPath.item - indexPath.item%7 + 7)
        
//        let result = weekRange.map { [weak self] (index: Int) -> (Int, DailyViewModel?) in
//            guard let self,
//                  let vm = self.dailyViewModels[self.mainDays[indexPath.section][index].date] else { return (0, nil) }
//            return (self.getDayHeight(viewModel: vm), vm)
//        }.max { $0.0 < $1.0 }
        
        var maxVM: DailyViewModel?
        var maxHeight: Int = 0
        for i in weekRange {
            let date = mainDays[indexPath.section][i].date
            
            let tmpVM = dailyViewModels[date]
            if let tmpVM {
                let a = getDayHeight(viewModel: tmpVM)
                if maxHeight < a {
                    maxVM = tmpVM
                    maxHeight = a
                }
            }
        }
        

        return (maxHeight, maxVM)
    }
}

// MARK: prepare TodosInDayViewModel
private extension MemberProfileViewModel {
    func generateDailyViewModel(at indexPath: IndexPath, singleTodos: [TodoSummaryViewModel], periodTodos: [TodoSummaryViewModel]) -> DailyViewModel {
        let filteredPeriodTodos: [(Int, TodoSummaryViewModel)] = periodTodos.compactMap { todo in
            for i in (0..<todoStackingBuffer[indexPath.item].count) {
                if todoStackingBuffer[indexPath.item][i] == false,
                   let period = calendar.dateComponents([.day], from: todo.startDate, to: todo.endDate).day {
                    for j in (0...period) {
                        todoStackingBuffer[indexPath.item+j][i] = true
                    }
                    return (i, todo)
                }
            }
            return nil
        }

        let singleTodoInitialIndex = (todoStackingBuffer[indexPath.item].lastIndex(where: { isFilled in
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
        
        return DailyViewModel(periodTodo: filteredPeriodTodos, singleTodo: filteredSingleTodos, holiday: holiday)
    }
    
    func prepareSingleTodosInDay(at indexPath: IndexPath, todos: [TodoSummaryViewModel]) -> [TodoSummaryViewModel] {
        return todos.filter { $0.startDate == $0.endDate }
    }
    
    func preparePeriodTodosInDay(at indexPath: IndexPath, todos: [TodoSummaryViewModel]) -> [TodoSummaryViewModel] {
        var periodList = todos.filter { $0.startDate != $0.endDate }
        let date = mainDays[indexPath.section][indexPath.item].date
        
        if indexPath.item % 7 != 0 {
            periodList = periodList.filter { $0.startDate == date }
                .sorted { $0.endDate < $1.endDate }
        } else {
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

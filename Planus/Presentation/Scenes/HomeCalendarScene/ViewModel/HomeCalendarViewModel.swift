//
//  HomeCalendarViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

final class HomeCalendarViewModel: ViewModel {
    
    struct UseCases {
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        
        let createTodoUseCase: CreateTodoUseCase
        let readTodoListUseCase: ReadTodoListUseCase
        let updateTodoUseCase: UpdateTodoUseCase
        let deleteTodoUseCase: DeleteTodoUseCase
        let todoCompleteUseCase: TodoCompleteUseCase
        
        let createCategoryUseCase: CreateCategoryUseCase
        let readCategoryListUseCase: ReadCategoryListUseCase
        let updateCategoryUseCase: UpdateCategoryUseCase
        let deleteCategoryUseCase: DeleteCategoryUseCase
        let fetchGroupCategoryListUseCase: FetchAllGroupCategoryListUseCase
        
        let fetchMyGroupNameListUseCase: FetchMyGroupNameListUseCase
        let groupCreateUseCase: GroupCreateUseCase
        let withdrawGroupUseCase: WithdrawGroupUseCase
        let deleteGroupUseCase: DeleteGroupUseCase
        
        let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
        let dateFormatYYYYMMUseCase: DateFormatYYYYMMUseCase
        
        let readProfileUseCase: ReadProfileUseCase
        let updateProfileUseCase: UpdateProfileUseCase
        let fetchImageUseCase: FetchImageUseCase
    }
    
    struct Actions {
        var showDailyCalendarPage: ((DailyCalendarViewModel.Args) -> Void)?
        var showCreatePeriodTodoPage: ((MemberTodoDetailViewModel.Args, (() -> Void)?) -> Void)?
        var showMyPage: ((Profile) -> Void)?
    }
    
    struct Args {}
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions

    let calendar: Calendar = sharedCalendar
    
    var filteredGroupId = BehaviorSubject<Int?>(value: nil)
    
    // for todoList caching
    let cachingIndexDiff = 8
    let cachingAmount = 10
    
    let endOfFirstIndex = -100
    let endOfLastIndex = 100
    
    var latestPrevCacheRequestedIndex = 0
    var latestFollowingCacheRequestedIndex = 0
    
    lazy var today: Date = {
        let components = self.calendar.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        
        return self.calendar.date(from: components) ?? Date()
    }()
    
    lazy var currentDate = BehaviorSubject<Date?>(value: {
        let components = self.calendar.dateComponents([.year, .month], from: Date())
        return self.calendar.date(from: components) ?? Date()
    }())
    var currentYYYYMM = BehaviorSubject<String?>(value: nil)

    var mainDays = [[Day]]()
    var todos = [Date: [Todo]]()
    
    // MARK: UI Generating caches
    var todoStackingCache = [[Bool]](repeating: [Bool](repeating: false, count: 20), count: 42) //투두 스택쌓는 용도, 블럭 사이에 자리 있는지 확인하는 애
    var weekDayChecker = [Int](repeating: -1, count: 6) //firstDayOfWeekChecker
    var todosInDayViewModels = [TodosInDayViewModel](repeating: TodosInDayViewModel(periodTodo: [], singleTodo: []), count: 42) //UI 표시용 뷰모델
    var cachedCellHeightForTodoCount = [Int: Double]()
    
    var groups = [Int: GroupName]()
    var memberCategories = [Int: Category]()
    var groupCategories = [Int: Category]()

    var nowRefreshing: Bool = false
    var didFinishRefreshing = PublishSubject<Void>()
    var initialDayListFetchedInCenterIndex = BehaviorSubject<Int?>(value: nil)
    var todoListFetchedInIndexRange = BehaviorSubject<(Int, Int)?>(value: nil)
    var showMonthPicker = PublishSubject<(Date, Date, Date)>()
    var didSelectMonth = PublishSubject<Int>()
    var needReloadSectionSet = PublishSubject<IndexSet>() //리로드 섹션을 해야함 왜?
    var needReloadData = PublishSubject<Void>()
    var needWelcome = BehaviorSubject<String?>(value: nil)
    var homeTabReselected: PublishSubject<Void>?
    
    var todoCompletionHandler: ((IndexPath) -> Void)?

    var profile: Profile?
    var fetchedProfileImage = BehaviorSubject<Data?>(value: nil)
    
    var initialReadCategory = BehaviorSubject<Void?>(value: nil)
    var initialReadGroupCategory = BehaviorSubject<Void?>(value: nil)
    var initialReadGroup = BehaviorSubject<Void?>(value: nil)
    
    var currentIndex = Int()
    
    struct Input {
        var didScrollToIndex: Observable<Int>
        var viewDidLoaded: Observable<Void>
        var didSelectItem: Observable<(Int, Int)>
        var didMultipleSelectItemsInRange: Observable<(Int, (Int, Int))>
        var didTappedTitleButton: Observable<Void>
        var didSelectMonth: Observable<Date>
        var filterGroupWithId: Observable<Int?>
        var refreshRequired: Observable<Void>
        var profileBtnTapped: Observable<Void>
    }
    
    struct Output {
        var didLoadYYYYMM: Observable<String?>
        var initialDayListFetchedInCenterIndex: Observable<Int?>
        var todoListFetchedInIndexRange: Observable<(Int, Int)?> // a부터 b까지 리로드 해라!
        var showMonthPicker: Observable<(Date, Date, Date)> //앞 현재 끝
        var monthChangedByPicker: Observable<Int> //인덱스만 알려주자!
        var needReloadSectionSet: Observable<IndexSet>
        var needReloadData: Observable<Void>
        var profileImageFetched: Observable<Data?>
        var needWelcome: Observable<String?>
        var groupListFetched: Observable<Void?>
        var needFilterGroupWithId: Observable<Int?>
        var didFinishRefreshing: Observable<Void>
        var needScrollToHome: Observable<Void>
    }
        
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
    }
    
    func transform(input: Input) -> Output {
        input.viewDidLoaded
            .withUnretained(self)
            .subscribe { vm, _ in
                guard let date = try? vm.currentDate.value() else { return }
                vm.bind()
                vm.fetchGroupAndCategory()
                vm.fetchProfile()
                vm.initCalendar(date: date)
                
                Observable.zip(
                    vm.initialReadGroup.compactMap { $0 },
                    vm.initialReadGroupCategory.compactMap { $0 },
                    vm.initialReadCategory.compactMap { $0 }
                )
                    .take(1)
                    .subscribe(onNext: { _ in
                        vm.initTodoList()
                    })
                    .disposed(by: vm.bag)
            }
            .disposed(by: bag)
        
        input
            .didScrollToIndex
            .withUnretained(self)
            .subscribe { vm, index in
                vm.scrolledTo(index: index)
            }
            .disposed(by: bag)
        
        input
            .didSelectItem
            .withUnretained(self)
            .subscribe { vm, index in
                let day = vm.mainDays[index.0][index.1]
                vm.actions.showDailyCalendarPage?(DailyCalendarViewModel.Args(
                    currentDate: day.date,
                    todoList: vm.todos[day.date] ?? [],
                    categoryDict: vm.memberCategories ,
                    groupDict: vm.groups ,
                    groupCategoryDict: vm.groupCategories ,
                    filteringGroupId: try? vm.filteredGroupId.value()
                ))
            }
            .disposed(by: bag)
        
        input
            .didMultipleSelectItemsInRange
            .withUnretained(self)
            .subscribe { vm, indexRange in
                vm.multipleDaysSelected(section: indexRange.0, items: indexRange.1)
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
                vm.initTodoList()
            })
            .disposed(by: bag)
        
        input.filterGroupWithId
            .bind(to: filteredGroupId)
            .disposed(by: bag)
                
        input
            .refreshRequired
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.nowRefreshing = true
                vm.todos = [:]
                vm.fetchAll()
            })
            .disposed(by: bag)
        
        input
            .profileBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let profile = vm.profile else { return }
                vm.actions.showMyPage?(profile)
            })
            .disposed(by: bag)
        
        let needScrollToHome = PublishSubject<Void>()
        
        homeTabReselected?
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.scrolledTo(index: -vm.endOfFirstIndex)
                vm.fetchAll()
                needScrollToHome.onNext(())
            })
            .disposed(by: bag)
        
        return Output(
            didLoadYYYYMM: currentYYYYMM.asObservable(),
            initialDayListFetchedInCenterIndex: initialDayListFetchedInCenterIndex.asObservable(),
            todoListFetchedInIndexRange: todoListFetchedInIndexRange.asObservable(),
            showMonthPicker: showMonthPicker.asObservable(),
            monthChangedByPicker: didSelectMonth.asObservable(),
            needReloadSectionSet: needReloadSectionSet.asObservable(),
            needReloadData: needReloadData.asObservable(),
            profileImageFetched: fetchedProfileImage.asObservable(),
            needWelcome: needWelcome.asObservable(),
            groupListFetched: initialReadGroup.asObservable(),
            needFilterGroupWithId: filteredGroupId.asObservable(),
            didFinishRefreshing: didFinishRefreshing.asObservable(),
            needScrollToHome: needScrollToHome.asObservable()
        )
    }
}

// MARK: Setters
private extension HomeCalendarViewModel {
    func setCategories(categories: [Category]) {
        self.memberCategories = [:]
        categories.forEach {
            guard let id = $0.id else { return }
            self.memberCategories[id] = $0
        }
    }
    
    func setGroupCategories(categories: [Category]) {
        self.groupCategories = [:]
        categories.forEach {
            guard let id = $0.id else { return }
            self.groupCategories[id] = $0
        }
    }
    
    func setGroups(groups: [GroupName]) {
        self.groups = [:]
        groups.forEach {
            self.groups[$0.groupId] = $0
        }
    }
}

// MARK: Calendar, Todo Generator
private extension HomeCalendarViewModel {
    func scrolledTo(index: Int) {
        currentIndex = index
        updateCurrentDate(index: index)
        checkCacheLoadNeed()
    }
    
    func checkCacheLoadNeed() {
        guard let currentDate = try? self.currentDate.value() else { return }
        if latestPrevCacheRequestedIndex - currentIndex == cachingIndexDiff {
            latestPrevCacheRequestedIndex = currentIndex
            let fromIndex = currentIndex - cachingAmount
            let toIndex = currentIndex - (cachingAmount - cachingIndexDiff)
            fetchTodoList(from: fromIndex, to: toIndex)
        } else if currentIndex - latestFollowingCacheRequestedIndex == cachingIndexDiff {
            latestFollowingCacheRequestedIndex = currentIndex
            let fromIndex = currentIndex + cachingAmount - cachingIndexDiff + 1
            let toIndex = currentIndex + cachingAmount + 1
            fetchTodoList(from: fromIndex, to: toIndex)
        }
    }
    
    func initCalendar(date: Date) {
        mainDays = (endOfFirstIndex...endOfLastIndex).map { diff -> [Day] in
            let calendarDate = self.calendar.date(byAdding: DateComponents(month: diff), to: date) ?? Date()
            return useCases.createMonthlyCalendarUseCase.execute(date: calendarDate)
        }
        currentIndex = -endOfFirstIndex
        latestPrevCacheRequestedIndex = currentIndex
        latestFollowingCacheRequestedIndex = currentIndex
        
        initialDayListFetchedInCenterIndex.onNext(currentIndex)
    }
    
    func initTodoList() { //index를 기점으로 초기화
        latestPrevCacheRequestedIndex = currentIndex
        latestFollowingCacheRequestedIndex = currentIndex
        
        let fromIndex = (currentIndex - cachingAmount >= 0) ? currentIndex - cachingAmount : 0
        let toIndex = currentIndex + cachingAmount + 1 < mainDays.count ? currentIndex + cachingAmount + 1 : mainDays.count-1
                
        fetchTodoList(from: fromIndex, to: toIndex)
    }
}

// MARK: UseCases Binding
private extension HomeCalendarViewModel {
    func bind() {
        guard let date = try? currentDate.value() else { return }
        currentDate
            .compactMap { $0 }
            .subscribe { [weak self] date in
                self?.updateTitle(date: date)
            }
            .disposed(by: bag)
        
        bindCategoryUseCase()
        bindTodoUseCase(initialDate: date)
        bindProfileUseCase()
        bindGroupUseCase()
    }
    
    func bindGroupUseCase() {
        useCases.groupCreateUseCase
            .didCreateGroup
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchAll()
            })
            .disposed(by: bag)
        
        useCases.withdrawGroupUseCase
            .didWithdrawGroup
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchAll()
            })
            .disposed(by: bag)
        
        useCases.deleteGroupUseCase
            .didDeleteGroupWithId
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchAll()
            })
            .disposed(by: bag)
    }
    
    func bindProfileUseCase() {
        useCases.updateProfileUseCase
            .didUpdateProfile
            .subscribe(onNext: { [weak self] profile in
            guard let self else { return }
            self.profile = profile
            guard let imageUrl = profile.imageUrl else {
                self.fetchedProfileImage.onNext(nil)
                return
            }
                self.useCases.fetchImageUseCase.execute(key: imageUrl)
                .subscribe(onSuccess: { data in
                    self.fetchedProfileImage.onNext(data)
                })
                .disposed(by: self.bag)
        })
        .disposed(by: bag)
    }
    
    func bindCategoryUseCase() {
        useCases.createCategoryUseCase
            .didCreateCategory
            .withUnretained(self)
            .subscribe(onNext: { vm, category in
                guard let id = category.id else { return }
                vm.memberCategories[id] = category
            })
            .disposed(by: bag)
        
        useCases.updateCategoryUseCase
            .didUpdateCategory
            .withUnretained(self)
            .subscribe(onNext: { vm, category in
                guard let id = category.id else { return }
                vm.memberCategories[id] = category
                vm.needReloadData.onNext(())
            })
            .disposed(by: bag)
    }
    
    func bindTodoUseCase(initialDate: Date) {
        guard let firstDate = calendar.date(
            byAdding: DateComponents(month: endOfFirstIndex),
            to: initialDate
        ) else { return }
        
        useCases.createTodoUseCase
            .didCreateTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                vm.createTodo(firstDate: firstDate, todo: todo)
            })
            .disposed(by: bag)
        
        useCases.updateTodoUseCase
            .didUpdateTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todoUpdate in
                vm.updateTodo(firstDate: firstDate, todoUpdate: todoUpdate)
            })
            .disposed(by: bag)
        
        useCases.deleteTodoUseCase
            .didDeleteTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                vm.deleteTodo(firstDate: firstDate, todo: todo)
            })
            .disposed(by: bag)
        
        useCases.todoCompleteUseCase
            .didCompleteTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                vm.completeTodo(firstDate: firstDate, todo: todo)
            })
            .disposed(by: bag)
    }
}

// MARK: Actions
private extension HomeCalendarViewModel {
    func createTodo(firstDate: Date, todo: Todo) {
        var sectionSet = IndexSet()
        
        var tmpDate = todo.startDate
        while(tmpDate <= todo.endDate) {
            if todos[tmpDate] == nil {
                todos[tmpDate] = []
            }
            todos[tmpDate]?.append(todo)
            let sectionIndex = calendar.dateComponents([.month], from: firstDate, to: tmpDate).month ?? 0
            let range = ((sectionIndex > 0) ? sectionIndex - 1 : sectionIndex)
            ...
            ((sectionIndex < endOfLastIndex - endOfFirstIndex) ? sectionIndex + 1 : sectionIndex)
            sectionSet.insert(integersIn: range)
            
            tmpDate = calendar.date(byAdding: DateComponents(day: 1), to: tmpDate) ?? Date()
        }

        needReloadSectionSet.onNext(sectionSet)
    }
    
    func completeTodo(firstDate: Date, todo: Todo) {
        var sectionSet = IndexSet()
                
        var tmpDate = todo.startDate
        while(tmpDate <= todo.endDate) {
            guard let todoIndex = todos[tmpDate]?.firstIndex(where: { $0.id == todo.id && $0.isGroupTodo == todo.isGroupTodo }) else { return }
            todos[tmpDate]?[todoIndex] = todo
            let sectionIndex = calendar.dateComponents([.month], from: firstDate, to: tmpDate).month ?? 0
            let range = ((sectionIndex > 0) ? sectionIndex - 1 : sectionIndex)
            ...
            ((sectionIndex < endOfLastIndex - endOfFirstIndex) ? sectionIndex + 1 : sectionIndex)
            sectionSet.insert(integersIn: range)
            
            tmpDate = calendar.date(byAdding: DateComponents(day: 1), to: tmpDate) ?? Date()
        }
        
        needReloadSectionSet.onNext(sectionSet)
    }

    func updateTodo(firstDate: Date, todoUpdate: TodoUpdateComparator) {
        
        let todoBeforeUpdate = todoUpdate.before
        let todoAfterUpdate = todoUpdate.after
        var sectionSet = IndexSet()
        
        var removingTmpDate = todoBeforeUpdate.startDate
        while removingTmpDate <= todoBeforeUpdate.endDate {
            todos[removingTmpDate]?.removeAll(where: { $0.id == todoBeforeUpdate.id && $0.isGroupTodo == todoBeforeUpdate.isGroupTodo })
            
            let sectionIndex = calendar.dateComponents([.month], from: firstDate, to: removingTmpDate).month ?? 0

            let range = ((sectionIndex > 0) ? sectionIndex - 1 : sectionIndex)
            ...
            ((sectionIndex < endOfLastIndex - endOfFirstIndex) ? sectionIndex + 1 : sectionIndex)
            sectionSet.insert(integersIn: range)
            
            removingTmpDate = calendar.date(byAdding: DateComponents(day: 1), to: removingTmpDate) ?? Date()
        }
        
        var addingTmpDate = todoAfterUpdate.startDate
        while addingTmpDate <= todoAfterUpdate.endDate {
            if todos[addingTmpDate] == nil {
                todos[addingTmpDate] = []
            }
            
            let memberTodos = todos[addingTmpDate]!.enumerated().filter { !$1.isGroupTodo }
            let indexOfMemberTodos = memberTodos.insertionIndexOf(
                (Int(), todoAfterUpdate),
                isOrderedBefore: { $0.element.id! < $1.element.id! }
            )
            
            let todoIndex = indexOfMemberTodos == memberTodos.count ? todos[addingTmpDate]!.count : memberTodos[indexOfMemberTodos].offset
            todos[addingTmpDate]?.insert(todoAfterUpdate, at: todoIndex)

            
            let sectionIndex = calendar.dateComponents([.month], from: firstDate, to: addingTmpDate).month ?? 0
            let range = ((sectionIndex > 0) ? sectionIndex - 1 : sectionIndex)
            ...
            ((sectionIndex < endOfLastIndex - endOfFirstIndex) ? sectionIndex + 1 : sectionIndex)
            sectionSet.insert(integersIn: range)
            addingTmpDate = calendar.date(byAdding: DateComponents(day: 1), to: addingTmpDate) ?? Date()
        }
        needReloadSectionSet.onNext(sectionSet)
    }
    
    func deleteTodo(firstDate: Date, todo: Todo) {
        
        var sectionSet = IndexSet()
        
        // todo의 startDate ~ endDate까지 추가만 하면됨. section은 어떻게 찾을건가???
        var tmpDate = todo.startDate
        while(tmpDate <= todo.endDate) {
            todos[tmpDate]?.removeAll(where: { $0.id == todo.id && $0.isGroupTodo == todo.isGroupTodo })
            let sectionIndex = calendar.dateComponents([.month], from: firstDate, to: tmpDate).month ?? 0
            let range = ((sectionIndex > 0) ? sectionIndex - 1 : sectionIndex)
            ...
            ((sectionIndex < endOfLastIndex - endOfFirstIndex) ? sectionIndex + 1 : sectionIndex)
            sectionSet.insert(integersIn: range)
            tmpDate = calendar.date(byAdding: DateComponents(day: 1), to: tmpDate) ?? Date()
        }

        needReloadSectionSet.onNext(sectionSet)
    }
    
    func multipleDaysSelected(section: Int, items: (Int, Int)) {
        var startDate = mainDays[section][items.0].date
        var endDate = mainDays[section][items.1].date
        
        if startDate > endDate {
            swap(&startDate, &endDate)
        }

        let groupList = Array(groups.values).sorted(by: { $0.groupId < $1.groupId })
        
        var groupName: GroupName?
        if let filteredGroupId = try? filteredGroupId.value(),
           let filteredGroupName = groups[filteredGroupId] {
            groupName = filteredGroupName
        }
        
        actions.showCreatePeriodTodoPage?(
            MemberTodoDetailViewModel.Args(
                groupList: groupList,
                mode: .new,
                todo: nil,
                category: nil,
                groupName: groupName,
                start: startDate,
                end: endDate
            )
        ) { [weak self] in
            self?.todoCompletionHandler?(IndexPath(item: 0, section: section))
        }
    }
}

// MARK: Fetch
private extension HomeCalendarViewModel {
    func fetchTodoList(from fromIndex: Int, to toIndex: Int) {
        
        guard let currentDate = try? self.currentDate.value() else { return }
        let fromMonth = calendar.date(byAdding: DateComponents(month: fromIndex - currentIndex), to: currentDate) ?? Date()
        let toMonth = calendar.date(byAdding: DateComponents(month: toIndex - currentIndex), to: currentDate) ?? Date()
        
        let fromMonthStart = calendar.date(byAdding: DateComponents(day: -7), to: calendar.startOfDay(for: fromMonth)) ?? Date()
        let toMonthStart = calendar.date(byAdding: DateComponents(day: 7), to: calendar.startOfDay(for: toMonth)) ?? Date()
        
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.readTodoListUseCase
                    .execute(token: token, from: fromMonthStart, to: toMonthStart)
            }
            .subscribe(onSuccess: { [weak self] todoDict in
                guard let self else { return } //만약 위로 스크롤해서 업데이트한거면 애를 초기화시켜버려야한다..!!!!
                self.todos.merge(todoDict) { (_, new) in new }
                self.todoListFetchedInIndexRange.onNext((fromIndex, toIndex))
                
                if self.nowRefreshing {
                    self.nowRefreshing = false
                    self.didFinishRefreshing.onNext(())
                }
            })
            .disposed(by: bag)
    }
    
    func fetchGroupAndCategory() {
        let groupFetcher = useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                self?.useCases.fetchMyGroupNameListUseCase.execute(token: token)
            }
        
        let categoryFetcher = useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                self?.useCases.readCategoryListUseCase.execute(token: token)
            }
        
        let groupCategoryFetcher = useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                self?.useCases.fetchGroupCategoryListUseCase.execute(token: token)
            }
        
        Single.zip(
            groupFetcher,
            categoryFetcher,
            groupCategoryFetcher
        )
        .subscribe(onSuccess: { [weak self] (groups, categories, groupCategories) in
            self?.setGroups(groups: groups)
            self?.setCategories(categories: categories)
            self?.setGroupCategories(categories: groupCategories)
            self?.initialReadCategory.onNext(())
            self?.initialReadGroupCategory.onNext(())
            self?.initialReadGroup.onNext(())
        })
        .disposed(by: bag)
    }
    
    func fetchAll() {
        initialReadGroup.onNext(nil)
        initialReadCategory.onNext(nil)
        initialReadGroupCategory.onNext(nil)
        
        fetchGroupAndCategory()
        
        Observable.zip(
            initialReadGroup.compactMap { $0 },
            initialReadGroupCategory.compactMap { $0 },
            initialReadCategory.compactMap { $0 }
        )
            .withUnretained(self)
            .take(1)
            .subscribe(onNext: { vm, _ in
                vm.initTodoList()
            })
            .disposed(by: bag)
    }
    
    func fetchProfile() {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.readProfileUseCase
                    .execute(token: token)
            }
            .subscribe(onSuccess: { [weak self] profile in
                guard let self else { return }
                
                self.needWelcome.onNext("\(profile.nickName)님 반갑습니다!")
                self.profile = profile

                guard let imageUrl = profile.imageUrl else {
                    self.fetchedProfileImage.onNext(nil)
                    return
                }
                self.useCases.fetchImageUseCase.execute(key: imageUrl)
                    .subscribe(onSuccess: { data in
                        self.fetchedProfileImage.onNext(data)
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
    }
}

// MARK: VC쪽이 UI용 투두 ViewModel 준비를 위해 요청
extension HomeCalendarViewModel {
    func stackTodosInDayViewModelOfWeek(at indexPath: IndexPath) {
        let date = mainDays[indexPath.section][indexPath.item].date
        if indexPath.item%7 == 0, //월요일만 진입 가능
           weekDayChecker[indexPath.item/7] != calendar.component(.weekOfYear, from: date) {
            weekDayChecker[indexPath.item/7] = calendar.component(.weekOfYear, from: date)
            (indexPath.item..<indexPath.item + 7).forEach { //해당주차의 todoStackingCache를 전부 0으로 초기화
                todoStackingCache[$0] = [Bool](repeating: false, count: 20)
            }
            
            for (item, day) in Array(mainDays[indexPath.section].enumerated())[indexPath.item..<indexPath.item + 7] {
                var todoList = todos[day.date] ?? []
                if let filterGroupId = try? filteredGroupId.value() {
                    todoList = todoList.filter( { $0.groupId == filterGroupId })
                }
                
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
    
    func maxHeightTodosInDayViewModelOfWeek(at indexPath: IndexPath) -> TodosInDayViewModel? {
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
private extension HomeCalendarViewModel {
    func generateTodosInDayViewModel(at indexPath: IndexPath, singleTodos: [Todo], periodTodos: [Todo]) -> TodosInDayViewModel {
        let filteredPeriodTodos: [(Int, Todo)] = periodTodos.compactMap { todo in
            for i in (0..<todoStackingCache[indexPath.item].count) {
                if todoStackingCache[indexPath.item][i] == false,
                   let period = calendar.dateComponents([.day], from: todo.startDate, to: todo.endDate).day {
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
        if let holidayTitle = HolidayPool.shared.holidays[mainDays[indexPath.section][indexPath.item].date] {
            let holidayIndex = singleTodoInitialIndex + singleTodos.count
            holiday = (holidayIndex, holidayTitle)
        }
        
        return TodosInDayViewModel(periodTodo: filteredPeriodTodos, singleTodo: filteredSingleTodos, holiday: holiday)
    }
    
    func prepareSingleTodosInDay(at indexPath: IndexPath, todos: [Todo]) -> [Todo] {
        return todos.filter { $0.startDate == $0.endDate }
    }
    
    func preparePeriodTodosInDay(at indexPath: IndexPath, todos: [Todo]) -> [Todo] {
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
        
        let firstDayOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))
        let lastDayOfWeek = calendar.date(byAdding: .day, value: 6, to: firstDayOfWeek!)!  //일요일임.
        
        return periodList.map { todo in
            let currentWeek = calendar.component(.weekOfYear, from: date)
            let endWeek = calendar.component(.weekOfYear, from: todo.endDate)
            
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

// MARK: Title Year-Month generator
private extension HomeCalendarViewModel {
    func updateTitle(date: Date) {
        currentYYYYMM.onNext(useCases.dateFormatYYYYMMUseCase.execute(date: date))
    }
    
    func updateCurrentDate(index: Int) {
        let firstDate = self.calendar.startDayOfMonth(date: mainDays[0][7].date)
        
        currentDate.onNext(self.calendar.date(
            byAdding: DateComponents(month: index),
            to: firstDate
        ))
    }
}

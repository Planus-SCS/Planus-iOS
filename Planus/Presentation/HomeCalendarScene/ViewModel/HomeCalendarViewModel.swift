//
//  HomeCalendarViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

struct FilteredTodoViewModel {
    var periodTodo: [(Int,Todo)] //offset, Todo
    var singleTodo: [(Int,Todo)] //offset, Todo
    var holiday: (Int, String)?
}

class HomeCalendarViewModel {
    
    var bag = DisposeBag()
    
    let calendar = Calendar.current
    
    var filteredGroupId = BehaviorSubject<Int?>(value: nil)
    
    // for todoList caching
    let cachingIndexDiff = 8
    let cachingAmount = 10
    
    let endOfFirstIndex = -100
    let endOfLastIndex = 500
    
    var latestPrevCacheRequestedIndex = 0
    var latestFollowingCacheRequestedIndex = 0
    
    lazy var today: Date = {
        let components = self.calendar.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        
        return self.calendar.date(from: components) ?? Date()
    }()
    
    var currentDate = BehaviorSubject<Date?>(value: nil)
    var currentYYYYMM = BehaviorSubject<String?>(value: nil)

    var mainDays = [[DayViewModel]]()
    var todos = [Date: [Todo]]()
    
    var blockMemo = [[(Int, Bool)?]](repeating: [(Int, Bool)?](repeating: nil, count: 20), count: 42) //todoId, groupTodo인가?
    var filteredTodoCache = [FilteredTodoViewModel](repeating: FilteredTodoViewModel(periodTodo: [], singleTodo: []), count: 42)
    var cachedCellHeightForTodoCount = [Int: Double]()
    
    var groups = [Int: GroupName]() //그룹 패치, 카테고리 패치, 달력 생성 완료되면? -> 달력안에 투두 뷰모델을 넣어두기..??? 이게 맞나???
    var memberCategories = [Int: Category]()
    var groupCategories = [Int: Category]()

    var nowRefreshing: Bool = false
    var didFinishRefreshing = PublishSubject<Void>()
    var initialDayListFetchedInCenterIndex = BehaviorSubject<Int?>(value: nil)
    var todoListFetchedInIndexRange = BehaviorSubject<(Int, Int)?>(value: nil)
    var showCreateMultipleTodo = PublishSubject<(Date, Date)>()
    var showDailyTodoPage = PublishSubject<DayViewModel>()
    var showMonthPicker = PublishSubject<(Date, Date, Date)>()
    var didSelectMonth = PublishSubject<Int>()
    var needReloadSectionSet = PublishSubject<IndexSet>() //리로드 섹션을 해야함 왜?
    var needReloadData = PublishSubject<Void>()
    var needWelcome = BehaviorSubject<String?>(value: nil)
    
    lazy var categoryAndGroupZip = Observable.zip(
        initialReadGroup.compactMap { $0 },
        initialReadGroupCategory.compactMap { $0 },
        initialReadCategory.compactMap { $0 }
    )
    
    var profile: Profile?
    var fetchedProfileImage = BehaviorSubject<Data?>(value: nil)
    
    var initialReadCategory = BehaviorSubject<Void?>(value: nil)
    var initialReadGroupCategory = BehaviorSubject<Void?>(value: nil)
    var initialReadGroup = BehaviorSubject<Void?>(value: nil)
    
    var currentIndex = Int()
    
    struct Input {
        var didScrollTo: Observable<ScrollDirection>
        var viewDidLoaded: Observable<Void>
        var didSelectItem: Observable<(Int, Int)>
        var didMultipleSelectItemsInRange: Observable<(Int, (Int, Int))>
        var didTappedTitleButton: Observable<Void>
        var didSelectMonth: Observable<Date>
        var filterGroupWithId: Observable<Int?>
        var refreshRequired: Observable<Void>
    }
    
    struct Output {
        var didLoadYYYYMM: Observable<String?>
        var initialDayListFetchedInCenterIndex: Observable<Int?>
        var todoListFetchedInIndexRange: Observable<(Int, Int)?> // a부터 b까지 리로드 해라!
        var showCreateMultipleTodo: Observable<(Date, Date)>
        var showDailyTodoPage: Observable<DayViewModel>
        var showMonthPicker: Observable<(Date, Date, Date)> //앞 현재 끝
        var monthChangedByPicker: Observable<Int> //인덱스만 알려주자!
        var needReloadSectionSet: Observable<IndexSet>
        var needReloadData: Observable<Void>
        var profileImageFetched: Observable<Data?>
        var needWelcome: Observable<String?>
        var groupListFetched: Observable<Void?>
        var needFilterGroupWithId: Observable<Int?>
        var didFinishRefreshing: Observable<Void>
    }
    
    let getTokenUseCase: GetTokenUseCase
    let refreshTokenUseCase: RefreshTokenUseCase
    
    let createTodoUseCase: CreateTodoUseCase
    let readTodoListUseCase: ReadTodoListUseCase
    let updateTodoUseCase: UpdateTodoUseCase
    let deleteTodoUseCase: DeleteTodoUseCase
    let todoCompleteUseCase: TodoCompleteUseCase
    
    let createCategoryUseCase: CreateCategoryUseCase
    let readCategoryListUseCase: ReadCategoryListUseCase
    let updateCategoryUseCase: UpdateCategoryUseCase
    let deleteCategoryUseCase: DeleteCategoryUseCase
    let fetchGroupCategoryListUseCase: FetchGroupCategoryListUseCase
    
    let fetchMyGroupNameListUseCase: FetchMyGroupNameListUseCase
    let groupCreateUseCase: GroupCreateUseCase
    let withdrawGroupUseCase: WithdrawGroupUseCase
    let deleteGroupUseCase: DeleteGroupUseCase
    
    let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
    let dateFormatYYYYMMUseCase: DateFormatYYYYMMUseCase
    
    let readProfileUseCase: ReadProfileUseCase
    let updateProfileUseCase: UpdateProfileUseCase
    let fetchImageUseCase: FetchImageUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        createTodoUseCase: CreateTodoUseCase,
        readTodoListUseCase: ReadTodoListUseCase,
        updateTodoUseCase: UpdateTodoUseCase,
        deleteTodoUseCase: DeleteTodoUseCase,
        todoCompleteUseCase: TodoCompleteUseCase,
        createCategoryUseCase: CreateCategoryUseCase,
        readCategoryListUseCase: ReadCategoryListUseCase,
        updateCategoryUseCase: UpdateCategoryUseCase,
        deleteCategoryUseCase: DeleteCategoryUseCase,
        fetchGroupCategoryListUseCase: FetchGroupCategoryListUseCase,
        fetchMyGroupNameListUseCase: FetchMyGroupNameListUseCase,
        groupCreateUseCase: GroupCreateUseCase,
        createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase,
        dateFormatYYYYMMUseCase: DateFormatYYYYMMUseCase,
        readProfileUseCase: ReadProfileUseCase,
        updateProfileUseCase: UpdateProfileUseCase,
        fetchImageUseCase: FetchImageUseCase,
        withdrawGroupUseCase: WithdrawGroupUseCase,
        deleteGroupUseCase: DeleteGroupUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        
        self.createTodoUseCase = createTodoUseCase
        self.readTodoListUseCase = readTodoListUseCase
        self.updateTodoUseCase = updateTodoUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
        self.todoCompleteUseCase = todoCompleteUseCase
        
        self.createCategoryUseCase = createCategoryUseCase
        self.readCategoryListUseCase = readCategoryListUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
        self.fetchGroupCategoryListUseCase = fetchGroupCategoryListUseCase
        
        self.fetchMyGroupNameListUseCase = fetchMyGroupNameListUseCase
        self.groupCreateUseCase = groupCreateUseCase
        self.createMonthlyCalendarUseCase = createMonthlyCalendarUseCase
        self.dateFormatYYYYMMUseCase = dateFormatYYYYMMUseCase
        self.readProfileUseCase = readProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.withdrawGroupUseCase = withdrawGroupUseCase
        self.deleteGroupUseCase = deleteGroupUseCase
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
                vm.fetchCategory()
                vm.fetchGroupCategory()
                vm.fetchGroup()
                vm.fetchProfile()
                vm.bindCategoryUseCase()
                vm.bindTodoUseCase(initialDate: date)
                vm.bindProfileUseCase()
                vm.bindGroupUseCase()
                vm.initCalendar(date: date)
                
                vm.categoryAndGroupZip
                    .take(1)
                    .subscribe(onNext: { _ in
                        vm.initTodoList()
                    })
                    .disposed(by: vm.bag)
            })
            .disposed(by: bag)
        
        // FIXME: testing subscribe
        initialReadGroup.subscribe(onNext: { print("group Fetched with \($0)")})
        initialReadCategory.subscribe(onNext: { print("category Fetched with \($0)")})
        initialReadGroupCategory.subscribe(onNext: { print("groupCategory Fetched with \($0)") })
        todoListFetchedInIndexRange.subscribe(onNext: { print("todo fetched with \($0)") })
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
            .didScrollTo
            .withUnretained(self)
            .subscribe { vm, direction in
                vm.scrolledTo(direction: direction)
            }
            .disposed(by: bag)
        
        input
            .didSelectItem
            .withUnretained(self)
            .subscribe { vm, index in
                vm.showDailyTodoPage.onNext(vm.mainDays[index.0][index.1])
            }
            .disposed(by: bag)
        
        input
            .didMultipleSelectItemsInRange
            .withUnretained(self)
            .subscribe { vm, indexRange in
                vm.showCreateMultipleTodo.onNext((
                    vm.mainDays[indexRange.0][indexRange.1.0].date,
                    vm.mainDays[indexRange.0][indexRange.1.1].date
                ))
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
                vm.fetchAll()
            })
            .disposed(by: bag)
        
        return Output(
            didLoadYYYYMM: currentYYYYMM.asObservable(),
            initialDayListFetchedInCenterIndex: initialDayListFetchedInCenterIndex.asObservable(),
            todoListFetchedInIndexRange: todoListFetchedInIndexRange.asObservable(),
            showCreateMultipleTodo: showCreateMultipleTodo.asObservable(),
            showDailyTodoPage: showDailyTodoPage.asObservable(),
            showMonthPicker: showMonthPicker.asObservable(),
            monthChangedByPicker: didSelectMonth.asObservable(),
            needReloadSectionSet: needReloadSectionSet.asObservable(),
            needReloadData: needReloadData.asObservable(),
            profileImageFetched: fetchedProfileImage.asObservable(),
            needWelcome: needWelcome.asObservable(),
            groupListFetched: initialReadGroup.asObservable(),
            needFilterGroupWithId: filteredGroupId.asObservable(),
            didFinishRefreshing: didFinishRefreshing.asObservable()
        )
    }
    
    func updateTitle(date: Date) {
        currentYYYYMM.onNext(dateFormatYYYYMMUseCase.execute(date: date))
    }
    
    func initCalendar(date: Date) {
        mainDays = (endOfFirstIndex...endOfLastIndex).map { diff -> [DayViewModel] in
            let calendarDate = self.calendar.date(byAdding: DateComponents(month: diff), to: date) ?? Date()
            return createMonthlyCalendarUseCase.execute(date: calendarDate)
        }
        currentIndex = -endOfFirstIndex
        latestPrevCacheRequestedIndex = currentIndex
        latestFollowingCacheRequestedIndex = currentIndex
        
        initialDayListFetchedInCenterIndex.onNext(currentIndex)
    }
    
    func fetchAll() { //네이밍 변경하자..!
        initialReadGroup.onNext(nil)
        initialReadCategory.onNext(nil)
        initialReadGroupCategory.onNext(nil)
        
        fetchGroup()
        fetchCategory()
        fetchGroupCategory()
        
        categoryAndGroupZip
            .withUnretained(self)
            .take(1)
            .subscribe(onNext: { vm, _ in
                // 여기서 categoryAndGroupZip이 세개의 뉴 데이터를 잘 받은 후 이부분이 실행되는지 보자..!                
                vm.initTodoList()
            })
            .disposed(by: bag)
    }
    
    func bindGroupUseCase() {
        groupCreateUseCase //그룹 생성이나 탈퇴 시 새로 fetch
            .didCreateGroup
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchAll()
            })
            .disposed(by: bag)
        
        withdrawGroupUseCase
            .didWithdrawGroup
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchAll()
            })
            .disposed(by: bag)
        
        deleteGroupUseCase
            .didDeleteGroupWithId
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchAll()
            })
            .disposed(by: bag)
    }
    
    func bindProfileUseCase() {
        updateProfileUseCase
            .didUpdateProfile
            .subscribe(onNext: { [weak self] profile in
            guard let self else { return }
            self.profile = profile
            guard let imageUrl = profile.imageUrl else {
                self.fetchedProfileImage.onNext(nil)
                return
            }
            self.fetchImageUseCase.execute(key: imageUrl)
                .subscribe(onSuccess: { data in
                    self.fetchedProfileImage.onNext(data)
                })
                .disposed(by: self.bag)
        })
        .disposed(by: bag)
    }
    
    func bindCategoryUseCase() {
        createCategoryUseCase
            .didCreateCategory
            .withUnretained(self)
            .subscribe(onNext: { vm, category in
                guard let id = category.id else { return }
                vm.memberCategories[id] = category
            })
            .disposed(by: bag)
        
        updateCategoryUseCase
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
        
        createTodoUseCase
            .didCreateTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                vm.createTodo(firstDate: firstDate, todo: todo)
            })
            .disposed(by: bag)
        
        updateTodoUseCase
            .didUpdateTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todoUpdate in
                vm.updateTodo(firstDate: firstDate, todoUpdate: todoUpdate)
            })
            .disposed(by: bag)
        
        deleteTodoUseCase
            .didDeleteTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                vm.deleteTodo(firstDate: firstDate, todo: todo)
            })
            .disposed(by: bag)
        
        todoCompleteUseCase
            .didCompleteTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                vm.completeTodo(firstDate: firstDate, todo: todo)
            })
            .disposed(by: bag)
    }
    
    func initTodoList() { //index를 기점으로 초기화
        latestPrevCacheRequestedIndex = currentIndex
        latestFollowingCacheRequestedIndex = currentIndex
        
        let fromIndex = (currentIndex - cachingAmount >= 0) ? currentIndex - cachingAmount : 0
        let toIndex = currentIndex + cachingAmount + 1 < mainDays.count ? currentIndex + cachingAmount + 1 : mainDays.count-1
        
        fetchTodoList(from: fromIndex, to: toIndex)
    }

    func scrolledTo(direction: ScrollDirection) {
        updateCurrentDate(direction: direction)
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
            currentIndex-=1
        case .right:
            currentDate.onNext(self.calendar.date(
                                byAdding: DateComponents(month: 1),
                                to: previousDate
                        ))
            currentIndex+=1
        case .none:
            return
        }
    }
    
    // 여기만 하면 이제 당분간은 투두 받아오는 부분 걱정도 없을듯? 근데 애니메이션을 어케 적용해야되냐?????
    func checkCacheLoadNeed() {
        guard let currentDate = try? self.currentDate.value() else { return }
        if latestPrevCacheRequestedIndex - currentIndex == cachingIndexDiff {
            latestPrevCacheRequestedIndex = currentIndex //90 - 110
            // 100에서 시작해서 92에 도달함. 리로드하고 어디부터? 83-90
            let fromIndex = currentIndex - cachingAmount // 92 - 10 - (10-8)
            let toIndex = currentIndex - (cachingAmount - cachingIndexDiff) //92 - (10-8) : 90
            fetchTodoList(from: fromIndex, to: toIndex)
            
            // 100에서 시작함 108에 도달함. 리로드 실시하고 어디부터 어디까지? 111 - 118 까지
            // 108에서 리로드를 했음. 현재는 119까지 있음. 그럼 이제 또 116에서 리로드가 이뤄지겠지?
        } else if currentIndex - latestFollowingCacheRequestedIndex == cachingIndexDiff {
            latestFollowingCacheRequestedIndex = currentIndex
            let fromIndex = currentIndex + cachingAmount - cachingIndexDiff + 1 // 108 + 10 - 8 + 1
            let toIndex = currentIndex + cachingAmount + 1 // 108 + 10
            fetchTodoList(from: fromIndex, to: toIndex)
        }
    }

    func fetchTodoList(from fromIndex: Int, to toIndex: Int) {
        
        guard let currentDate = try? self.currentDate.value() else { return }
        let fromMonth = calendar.date(byAdding: DateComponents(month: fromIndex - currentIndex), to: currentDate) ?? Date()
        let toMonth = calendar.date(byAdding: DateComponents(month: toIndex - currentIndex), to: currentDate) ?? Date()
        
        let fromMonthStart = calendar.date(byAdding: DateComponents(day: -7), to: calendar.startOfDay(for: fromMonth)) ?? Date()
        let toMonthStart = calendar.date(byAdding: DateComponents(day: 7), to: calendar.startOfDay(for: toMonth)) ?? Date()

        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Date: [Todo]]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.readTodoListUseCase
                    .execute(token: token, from: fromMonthStart, to: toMonthStart)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] todoDict in
                guard let self else { return }
                self.todos.merge(todoDict) { (_, new) in new }
                self.todoListFetchedInIndexRange.onNext((fromIndex, toIndex))
                
                if self.nowRefreshing {
                    self.nowRefreshing = false
                    self.didFinishRefreshing.onNext(())
                }
            })
            .disposed(by: bag)
    }
    
    func fetchCategory() {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Category]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.readCategoryListUseCase
                    .execute(token: token)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] list in
                list.forEach {
                    guard let id = $0.id else { return }
                    self?.memberCategories[id] = $0
                }
                self?.initialReadCategory.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchGroupCategory() {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Category]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchGroupCategoryListUseCase
                    .execute(token: token)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] list in
                list.forEach {
                    guard let id = $0.id else { return }
                    self?.groupCategories[id] = $0
                }
                self?.initialReadGroupCategory.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchGroup() {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[GroupName]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMyGroupNameListUseCase
                    .execute(token: token)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] list in
                list.forEach {
                    self?.groups[$0.groupId] = $0
                }
                self?.initialReadGroup.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchProfile() {
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Profile> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.readProfileUseCase
                    .execute(token: token)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] profile in
                guard let self else { return }
                
                self.needWelcome.onNext("\(profile.nickName)님 반갑습니다!")
                self.profile = profile

                guard let imageUrl = profile.imageUrl else {
                    self.fetchedProfileImage.onNext(nil)
                    return
                }
                self.fetchImageUseCase.execute(key: imageUrl)
                    .subscribe(onSuccess: { data in
                        self.fetchedProfileImage.onNext(data)
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
    }
    
    func createTodo(firstDate: Date, todo: Todo) {

        var sectionSet = IndexSet()
        
        // todo의 startDate ~ endDate까지 추가만 하면됨. section은 어떻게 찾을건가???
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
        // 지금 방식 너무 복잡함..! 그냥 무조건 삭제하고 다시 추가하는 방식으로 가자..!
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
    
    func getMaxCountInWeek(indexPath: IndexPath) -> (offset: Int, element: FilteredTodoViewModel) {
        let item = indexPath.item
        let section = indexPath.section
        
        // 한 주차 내에서만 구해야함
        let maxItem = Array(filteredTodoCache.enumerated())[indexPath.item - indexPath.item%7..<indexPath.item + 7 - indexPath.item%7].max(by: { a, b in
            a.element.periodTodo.count + a.element.singleTodo.count < b.element.periodTodo.count + b.element.singleTodo.count
        }) ?? (offset: Int(), element: FilteredTodoViewModel(periodTodo: [], singleTodo: []))
        
        return maxItem
    }
    
    func generateFilteredTodoOffsetOfWeek(indexPath: IndexPath) {
        
    }
}


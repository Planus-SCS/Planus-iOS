//
//  HomeCalendarViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

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
    
    var currentDate = BehaviorSubject<Date?>(value: nil)
    var currentYYYYMM = BehaviorSubject<String?>(value: nil)

    var mainDayList = [[DayViewModel]]()
    
    var groupDict = [Int: GroupName]() //그룹 패치, 카테고리 패치, 달력 생성 완료되면? -> 달력안에 투두 뷰모델을 넣어두기..??? 이게 맞나???
    var categoryDict = [Int: Category]()
    
    
    //투두는 왜 투두용 뷰모델을 쓰지 않았는가?? -> 카테고리를 채워넣기엔 이거 업댓할때 카테고리까지 싹다 업뎃되면 머리아프니까.. 일단 하던대로 하자
    // 이거 일단 받아오는순서
    /*
     1. 그룹, 카테고리 받아오기
     2. 달력 그리기(이건 1이랑 같이 그려도 되고 투두 다받아오면 그때 보여줘도 상관없을듯
     3. 투두받아오는건 무적권 그룹, 카테고리 받아오는게 끝나있어야한다!
     근데 그룹, 카테고리를 subject로 할까 그냥할까? behavior로 일단 하자...!!!
     그럼 두개 받아오는거의 combinelatest써서 첫 1회만 투두 받아오는걸 시작하자..!!!
     그다음부터는.... 카테고리가 업댓될때마다 리로드
     그리고 그룹이 업데이트(가입하거나 탈퇴하거나)할때마다,,, 그룹 탈퇴는 아에 투두목록에서 싹다 해당 그룹을 지워야함... 그룹가입도 비슷함,,,
     */

    var initialDayListFetchedInCenterIndex = BehaviorSubject<Int?>(value: nil)
    var todoListFetchedInIndexRange = BehaviorSubject<(Int, Int)?>(value: nil)
    var showCreateMultipleTodo = PublishSubject<(Date, Date)>()
    var showDailyTodoPage = PublishSubject<DayViewModel>()
    var showMonthPicker = PublishSubject<(Date, Date, Date)>()
    var didSelectMonth = PublishSubject<Int>()
    var needReloadSectionSet = PublishSubject<IndexSet>() //리로드 섹션을 해야함 왜?
    var needReloadData = PublishSubject<Void>()
    var needWelcome = BehaviorSubject<String?>(value: nil)
    
    var profile: Profile?
    var fetchedProfileImage = PublishSubject<Data?>()
    
    var initialReadCategory = BehaviorSubject<Void?>(value: nil)
    var initialReadGroup = BehaviorSubject<Void?>(value: nil)
    
    var currentIndex = Int()
    var cachedCellHeightForTodoCount = [Int: Double]()
    
    
    struct Input {
        var didScrollTo: Observable<ScrollDirection>
        var viewDidLoaded: Observable<Void>
        var didSelectItem: Observable<(Int, Int)>
        var didMultipleSelectItemsInRange: Observable<(Int, (Int, Int))>
        var didTappedTitleButton: Observable<Void>
        var didSelectMonth: Observable<Date>
        var filterGroupWithId: Observable<Int>
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
    }
    
    let getTokenUseCase: GetTokenUseCase
    let refreshTokenUseCase: RefreshTokenUseCase
    
    let createTodoUseCase: CreateTodoUseCase
    let readTodoListUseCase: ReadTodoListUseCase
    let updateTodoUseCase: UpdateTodoUseCase
    let deleteTodoUseCase: DeleteTodoUseCase
    
    let createCategoryUseCase: CreateCategoryUseCase
    let readCategoryListUseCase: ReadCategoryListUseCase
    let updateCategoryUseCase: UpdateCategoryUseCase
    let deleteCategoryUseCase: DeleteCategoryUseCase
    
    let fetchMyGroupNameListUseCase: FetchMyGroupNameListUseCase
    
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
        createCategoryUseCase: CreateCategoryUseCase,
        readCategoryListUseCase: ReadCategoryListUseCase,
        updateCategoryUseCase: UpdateCategoryUseCase,
        deleteCategoryUseCase: DeleteCategoryUseCase,
        fetchMyGroupNameListUseCase: FetchMyGroupNameListUseCase,
        createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase,
        dateFormatYYYYMMUseCase: DateFormatYYYYMMUseCase,
        readProfileUseCase: ReadProfileUseCase,
        updateProfileUseCase: UpdateProfileUseCase,
        fetchImageUseCase: FetchImageUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        
        self.createTodoUseCase = createTodoUseCase
        self.readTodoListUseCase = readTodoListUseCase
        self.updateTodoUseCase = updateTodoUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
        self.createCategoryUseCase = createCategoryUseCase
        self.readCategoryListUseCase = readCategoryListUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
        self.fetchMyGroupNameListUseCase = fetchMyGroupNameListUseCase
        self.createMonthlyCalendarUseCase = createMonthlyCalendarUseCase
        self.dateFormatYYYYMMUseCase = dateFormatYYYYMMUseCase
        self.readProfileUseCase = readProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.fetchImageUseCase = fetchImageUseCase
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
                vm.fetchCategoryAndGroup()
                vm.fetchProfile()
                vm.bindCategoryUseCase()
                vm.bindTodoUseCase(initialDate: date)
                vm.initCalendar(date: date)
                vm.bindProfileUseCase()
                Observable.combineLatest(
                    vm.initialReadGroup.compactMap { $0 },
                    vm.initialReadCategory.compactMap { $0 }
                )
                .subscribe(onNext: { _ in
                    vm.initTodoList(date: date)
                })
                .disposed(by: vm.bag)
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
                vm.showDailyTodoPage.onNext(vm.mainDayList[index.0][index.1])
            }
            .disposed(by: bag)
        
        input
            .didMultipleSelectItemsInRange
            .withUnretained(self)
            .subscribe { vm, indexRange in
                vm.showCreateMultipleTodo.onNext((
                    vm.mainDayList[indexRange.0][indexRange.1.0].date,
                    vm.mainDayList[indexRange.0][indexRange.1.1].date
                ))
            }
            .disposed(by: bag)
        
        input
            .didTappedTitleButton
            .withUnretained(self)
            .subscribe { vm, _ in
                guard let currentDate = try? vm.currentDate.value() else { return }
                let first = vm.mainDayList[0][7].date
                let last = vm.mainDayList[vm.mainDayList.count-1][7].date
                vm.showMonthPicker.onNext((first, currentDate, last))
            }
            .disposed(by: bag)
        
        input.didSelectMonth
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vm, date in
                let start = vm.mainDayList[0][7].date
                let index = vm.calendar.dateComponents([.month], from: vm.calendar.startDayOfMonth(date: start), to: date).month ?? 0
                vm.currentIndex = index
                vm.currentDate.onNext(date)
                vm.didSelectMonth.onNext(index)
                vm.initTodoList(date: date)
            })
            .disposed(by: bag)
        
        input.filterGroupWithId
            .bind(to: filteredGroupId)
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
            needFilterGroupWithId: filteredGroupId.asObservable()
        )
    }
    
    func updateTitle(date: Date) {
        currentYYYYMM.onNext(dateFormatYYYYMMUseCase.execute(date: date))
    }
    
    func initCalendar(date: Date) {
        mainDayList = (endOfFirstIndex...endOfLastIndex).map { diff -> [DayViewModel] in
            let calendarDate = self.calendar.date(byAdding: DateComponents(month: diff), to: date) ?? Date()
            return createMonthlyCalendarUseCase.execute(date: calendarDate)
        }
        currentIndex = -endOfFirstIndex
        latestPrevCacheRequestedIndex = currentIndex
        latestFollowingCacheRequestedIndex = currentIndex
        
        initialDayListFetchedInCenterIndex.onNext(currentIndex)
        // 여기서 바인딩 할것인가?
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
                vm.categoryDict[id] = category
            })
            .disposed(by: bag)
        
        updateCategoryUseCase
            .didUpdateCategory
            .withUnretained(self)
            .subscribe(onNext: { vm, category in
                guard let id = category.id else { return }
                vm.categoryDict[id] = category
                vm.needReloadData.onNext(())
            })
            .disposed(by: bag)
        
//        deleteCategoryUseCase
//            .didDeleteCategory
//            .withUnretained(self)
//            .subscribe(onNext: { vm, id in
//                guard var category = vm.categoryDict[id] else { return }
//                category.status = .inactive
//                vm.categoryDict[id] = category
//            })
//            .disposed(by: bag)
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
    }
    
    func initTodoList(date: Date) {
        let fromIndex = (currentIndex - cachingAmount >= 0) ? currentIndex - cachingAmount : 0
        let toIndex = currentIndex + cachingAmount + 1 < mainDayList.count ? currentIndex + cachingAmount + 1 : mainDayList.count-1
        
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
                (fromIndex..<toIndex).forEach { index in
                    self.mainDayList[index] = self.mainDayList[index].map {
                        guard let todoList = todoDict[$0.date] else {
                            return $0
                        }
                        var dayViewModel = $0
                        dayViewModel.todoList = todoList
                        return dayViewModel
                    }
                }
                self.todoListFetchedInIndexRange.onNext((fromIndex, toIndex))
            })
            .disposed(by: bag)
    }
    
    func fetchCategoryAndGroup() {
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
                    self?.categoryDict[id] = $0
                }
                self?.initialReadCategory.onNext(())
            })
            .disposed(by: bag)
        
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
                    self?.groupDict[$0.groupId] = $0
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
        let date = todo.startDate
        let monthIndex = calendar.dateComponents([.month], from: firstDate, to: date).month ?? 0
        
        var sectionSet = IndexSet()
        
        if monthIndex > 0,
           let prevDayIndex = mainDayList[monthIndex - 1].firstIndex(where: { $0.date == date }) {
            mainDayList[monthIndex - 1][prevDayIndex].todoList.append(todo)
            sectionSet.insert(monthIndex - 1)
        }
        if let dayIndex = mainDayList[monthIndex].firstIndex(where: { $0.date == date }) {
            mainDayList[monthIndex][dayIndex].todoList.append(todo)
            sectionSet.insert(monthIndex)
        }
        if monthIndex < mainDayList.count - 1,
           let followingDayIndex = mainDayList[monthIndex + 1].firstIndex(where: { $0.date == date}) {
            mainDayList[monthIndex + 1][followingDayIndex].todoList.append(todo)
            sectionSet.insert(monthIndex + 1)
        }
        
        needReloadSectionSet.onNext(sectionSet)
    }
    
    // 만약 날짜가 바뀐다면...???
    func updateTodo(firstDate: Date, todoUpdate: TodoUpdateComparator) {
        
        let todoBeforeUpdate = todoUpdate.before
        let todoAfterUpdate = todoUpdate.after
                
        let befMonthIndex = calendar.dateComponents([.month], from: firstDate, to: todoBeforeUpdate.startDate).month ?? 0
        let befDayIndex = mainDayList[befMonthIndex].firstIndex(where: { $0.date == todoBeforeUpdate.startDate }) ?? 0
        let afterMonthIndex = calendar.dateComponents([.month], from: firstDate, to: todoAfterUpdate.startDate).month ?? 0
        let afterDayIndex = mainDayList[afterMonthIndex].firstIndex(where: { $0.date == todoAfterUpdate.startDate }) ?? 0
        var sectionSet = IndexSet()
        
        if befMonthIndex == afterMonthIndex,
           befDayIndex == afterDayIndex {
            if afterMonthIndex > 0,
               let prevDayIndex = mainDayList[afterMonthIndex - 1].firstIndex(where: { $0.date == todoAfterUpdate.startDate }),
               let todoIndex = mainDayList[afterMonthIndex - 1][prevDayIndex].todoList.firstIndex(where: { $0.id == todoAfterUpdate.id }) {
                mainDayList[afterMonthIndex - 1][prevDayIndex].todoList[todoIndex] = todoAfterUpdate
                sectionSet.insert(afterMonthIndex - 1)
            }
            
            if let dayIndex = mainDayList[afterMonthIndex].firstIndex(where: { $0.date == todoAfterUpdate.startDate }),
               let todoIndex = mainDayList[afterMonthIndex][dayIndex].todoList.firstIndex(where: { $0.id == todoAfterUpdate.id }) {
                mainDayList[afterMonthIndex][dayIndex].todoList[todoIndex] = todoAfterUpdate
                sectionSet.insert(afterMonthIndex)
            }
            
            if afterMonthIndex < mainDayList.count - 1,
               let followingDayIndex = mainDayList[afterMonthIndex + 1].firstIndex(where: { $0.date == todoAfterUpdate.startDate}),
               let todoIndex = mainDayList[afterMonthIndex + 1][followingDayIndex].todoList.firstIndex(where: { $0.id == todoAfterUpdate.id }) {
                mainDayList[afterMonthIndex + 1][followingDayIndex].todoList[todoIndex] = todoAfterUpdate
                sectionSet.insert(afterMonthIndex + 1)
            }
        } else {
            // MARK: Remove Todo
            if befMonthIndex > 0,
               let prevDayIndex = mainDayList[befMonthIndex - 1].firstIndex(where: { $0.date == todoBeforeUpdate.startDate }),
               let todoIndex = mainDayList[befMonthIndex - 1][prevDayIndex].todoList.firstIndex(where: { $0.id == todoBeforeUpdate.id }) {
                mainDayList[befMonthIndex - 1][prevDayIndex].todoList.remove(at: todoIndex)
                sectionSet.insert(befMonthIndex - 1)
            }
            
            if let todoIndex = mainDayList[befMonthIndex][befDayIndex].todoList.firstIndex(where: { $0.id == todoBeforeUpdate.id }) {
                mainDayList[befMonthIndex][befDayIndex].todoList.remove(at: todoIndex)
                sectionSet.insert(befMonthIndex)
            }
            
            if befMonthIndex < mainDayList.count - 1,
               let followingDayIndex = mainDayList[befMonthIndex + 1].firstIndex(where: { $0.date == todoBeforeUpdate.startDate}),
               let todoIndex = mainDayList[befMonthIndex + 1][followingDayIndex].todoList.firstIndex(where: { $0.id == todoBeforeUpdate.id }) {
                mainDayList[befMonthIndex + 1][followingDayIndex].todoList.remove(at: todoIndex)
                sectionSet.insert(befMonthIndex + 1)
            }
            
            // MARK: Create Todo
            if afterMonthIndex > 0,
               let prevDayIndex = mainDayList[afterMonthIndex - 1].firstIndex(where: { $0.date == todoAfterUpdate.startDate }) {
                // 그냥 append 하면 안됨! index 찾아서 사이에 끼워넣어야함..!
                let todoIndex = mainDayList[afterMonthIndex - 1][prevDayIndex].todoList.insertionIndexOf(todoAfterUpdate) {
                    $0.id ?? Int() < $1.id ?? Int()
                }
                mainDayList[afterMonthIndex - 1][prevDayIndex].todoList.insert(todoAfterUpdate, at: todoIndex)
                sectionSet.insert(afterMonthIndex - 1)
            }
            
            let todoIndex = mainDayList[afterMonthIndex][afterDayIndex].todoList.insertionIndexOf(todoAfterUpdate) {
                $0.id ?? Int() < $1.id ?? Int()
            }
            print(mainDayList[afterMonthIndex][afterDayIndex].todoList.count, todoIndex)
            mainDayList[afterMonthIndex][afterDayIndex].todoList.insert(todoAfterUpdate, at: todoIndex)
            sectionSet.insert(afterMonthIndex)
            
            if afterMonthIndex < mainDayList.count - 1,
               let followingDayIndex = mainDayList[afterMonthIndex + 1].firstIndex(where: { $0.date == todoAfterUpdate.startDate}) {
                let todoIndex = mainDayList[afterMonthIndex - 1][followingDayIndex].todoList.insertionIndexOf(todoAfterUpdate) {
                    $0.id ?? Int() < $1.id ?? Int()
                }
                mainDayList[afterMonthIndex + 1][followingDayIndex].todoList.insert(todoAfterUpdate, at: todoIndex)
                sectionSet.insert(afterMonthIndex + 1)
            }
        }
        
        needReloadSectionSet.onNext(sectionSet)
    }
    
    func deleteTodo(firstDate: Date, todo: Todo) {
        let date = todo.startDate
        let monthIndex = calendar.dateComponents([.month], from: firstDate, to: date).month ?? 0
        
        var sectionSet = IndexSet()

        if monthIndex > 0,
           let prevDayIndex = mainDayList[monthIndex - 1].firstIndex(where: { $0.date == date }),
           let todoIndex = mainDayList[monthIndex - 1][prevDayIndex].todoList.firstIndex(where: { $0.id == todo.id }) {
            mainDayList[monthIndex - 1][prevDayIndex].todoList.remove(at: todoIndex)
            sectionSet.insert(monthIndex - 1)
        }
        
        if let dayIndex = mainDayList[monthIndex].firstIndex(where: { $0.date == date }),
           let todoIndex = mainDayList[monthIndex][dayIndex].todoList.firstIndex(where: { $0.id == todo.id }) {
            mainDayList[monthIndex][dayIndex].todoList.remove(at: todoIndex)
            sectionSet.insert(monthIndex)
        }
        
        if monthIndex < mainDayList.count - 1,
           let followingDayIndex = mainDayList[monthIndex + 1].firstIndex(where: { $0.date == date}),
           let todoIndex = mainDayList[monthIndex + 1][followingDayIndex].todoList.firstIndex(where: { $0.id == todo.id }) {
            mainDayList[monthIndex + 1][followingDayIndex].todoList.remove(at: todoIndex)
            sectionSet.insert(monthIndex + 1)
        }
        
        needReloadSectionSet.onNext(sectionSet)
    }
    
    func getMaxInWeek(indexPath: IndexPath) -> DayViewModel {
        let item = indexPath.item
        let section = indexPath.section
        
        var maxItem: Int
        if let filteredGroupId = try? filteredGroupId.value() {
            maxItem = ((item-item%7)..<(item+7-item%7)).max(by: { (a,b) in
                mainDayList[section][a].todoList.filter { $0.groupId == filteredGroupId }.count < mainDayList[section][b].todoList.filter { $0.groupId == filteredGroupId }.count
            }) ?? Int()
        } else {
            maxItem = ((item-item%7)..<(item+7-item%7)).max(by: { (a,b) in
                mainDayList[section][a].todoList.count < mainDayList[section][b].todoList.count
            }) ?? Int()
        }
        
        return mainDayList[indexPath.section][maxItem]
    }

}


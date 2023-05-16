//
//  MemberProfileViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import Foundation
import RxSwift

class MemberProfileViewModel {
    var bag = DisposeBag()
        
    let calendar = Calendar.current
    
    var groupId: Int?
    var member: MyMember?
    
    // for todoList caching
    let cachingIndexDiff = 8
    let cachingAmount = 10
    
    let endOfFirstIndex = -24
    let endOfLastIndex = 24
    
    var latestPrevCacheRequestedIndex = 0
    var latestFollowingCacheRequestedIndex = 0
    
    var currentDate = BehaviorSubject<Date?>(value: nil)
    var currentYYYYMM = BehaviorSubject<String?>(value: nil)

    var categoryDict = [Int: Category]()
    var mainDayList = [[DayViewModel]]()

    var initialDayListFetchedInCenterIndex = BehaviorSubject<Int?>(value: nil)
    var todoListFetchedInIndexRange = BehaviorSubject<(Int, Int)?>(value: nil)
    var categoryFetched = BehaviorSubject<Void?>(value: nil)
    var needReloadSection = BehaviorSubject<IndexSet?>(value: nil)
    
    var showDailyTodoPage = PublishSubject<DayViewModel>()
    var showMonthPicker = PublishSubject<(Date, Date, Date)>()
    var didSelectMonth = PublishSubject<Int>()
    
    var currentIndex = Int()
    var cachedCellHeightForTodoCount = [Int: Double]()
    
    struct Input {
        var didScrollTo: Observable<ScrollDirection>
        var viewDidLoaded: Observable<Void>
        var didSelectItem: Observable<IndexPath>
        var didTappedTitleButton: Observable<Void>
        var didSelectMonth: Observable<Date>
    }
    
    struct Output {
        var didLoadYYYYMM: Observable<String?>
        var initialDayListFetchedInCenterIndex: Observable<Int?>
        var needReloadSectionInRange: Observable<IndexSet?> // a부터 b까지 리로드 해라!
        var showDailyTodoPage: Observable<DayViewModel>
        var showMonthPicker: Observable<(Date, Date, Date)> //앞 현재 끝
        var monthChangedByPicker: Observable<Int> //인덱스만 알려주자!
        var memberName: String?
        var memberDesc: String?
        var memberImageUrl: String?
    }
    
    let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
    let dateFormatYYYYMMUseCase: DateFormatYYYYMMUseCase
    let getTokenUseCase: GetTokenUseCase
    let refreshTokenUseCase: RefreshTokenUseCase
    let fetchMemberTodoUseCase: FetchMemberTodoListUseCase
    let fetchMemberCategoryUseCase: FetchMemberCategoryUseCase
    let fetchImageUseCase: FetchImageUseCase
    
    init(
        createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase,
        fetchMemberTodoUseCase: FetchMemberTodoListUseCase,
        dateFormatYYYYMMUseCase: DateFormatYYYYMMUseCase,
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchMemberCategoryUseCase: FetchMemberCategoryUseCase,
        fetchImageUseCase: FetchImageUseCase
    ) {
        self.createMonthlyCalendarUseCase = createMonthlyCalendarUseCase
        self.fetchMemberTodoUseCase = fetchMemberTodoUseCase
        self.dateFormatYYYYMMUseCase = dateFormatYYYYMMUseCase
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchMemberCategoryUseCase = fetchMemberCategoryUseCase
        self.fetchImageUseCase = fetchImageUseCase
    }
    
    func setMember(groupId: Int, member: MyMember) {
        self.groupId = groupId
        self.member = member
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
                vm.fetchCategoryList()
                vm.initTodoList(date: date)
            })
            .disposed(by: bag)
        
//        Observable.zip(
//            categoryFetched.compactMap { $0 },
            todoListFetchedInIndexRange.compactMap { $0 }
        //)
        .withUnretained(self)
        .subscribe(onNext: { vm, arg in
            let from = arg.0
            let to = arg.1
            vm.needReloadSection.onNext(IndexSet(from..<to))
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
            .subscribe { vm, indexPath in
                vm.showDailyTodoPage.onNext(vm.mainDayList[indexPath.section][indexPath.item])
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
        
        return Output(
            didLoadYYYYMM: currentYYYYMM.asObservable(),
            initialDayListFetchedInCenterIndex: initialDayListFetchedInCenterIndex.asObservable(),
            needReloadSectionInRange: needReloadSection.asObservable(),
            showDailyTodoPage: showDailyTodoPage.asObservable(),
            showMonthPicker: showMonthPicker.asObservable(),
            monthChangedByPicker: didSelectMonth.asObservable(),
            memberName: member?.nickname,
            memberDesc: member?.description,
            memberImageUrl: member?.profileImageUrl
        )
    }
    
    func updateTitle(date: Date) {
        currentYYYYMM.onNext(dateFormatYYYYMMUseCase.execute(date: date))
    }
    
    func initCalendar(date: Date) {
        mainDayList = (endOfFirstIndex...endOfLastIndex).map { difference -> [DayViewModel] in
            let calendarDate = self.calendar.date(byAdding: DateComponents(month: difference), to: date) ?? Date()
            return createMonthlyCalendarUseCase.execute(date: calendarDate)
        }
        currentIndex = -endOfFirstIndex
        latestPrevCacheRequestedIndex = currentIndex
        latestFollowingCacheRequestedIndex = currentIndex
        
        initialDayListFetchedInCenterIndex.onNext(currentIndex)
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
    
    func checkCacheLoadNeed() {
        guard let currentDate = try? self.currentDate.value() else { return }
        if latestPrevCacheRequestedIndex - currentIndex == cachingIndexDiff {
            latestPrevCacheRequestedIndex = currentIndex //90 - 110
            // 100에서 시작해서 92에 도달함. 리로드하고 어디부터? 83-90
            let fromIndex = currentIndex - cachingAmount // 92 - 10 - (10-8)
            let toIndex = currentIndex - (cachingAmount - cachingIndexDiff) //92 - (10-8) : 90
            fetch(from: fromIndex, to: toIndex)
            
            // 100에서 시작함 108에 도달함. 리로드 실시하고 어디부터 어디까지? 111 - 118 까지
            // 108에서 리로드를 했음. 현재는 119까지 있음. 그럼 이제 또 116에서 리로드가 이뤄지겠지?
        } else if currentIndex - latestFollowingCacheRequestedIndex == cachingIndexDiff {
            latestFollowingCacheRequestedIndex = currentIndex
            let fromIndex = currentIndex + cachingAmount - cachingIndexDiff + 1 // 108 + 10 - 8 + 1
            let toIndex = currentIndex + cachingAmount + 1 // 108 + 10
            fetch(from: fromIndex, to: toIndex)
        }
    }
    
    func fetch(from fromIndex: Int, to toIndex: Int) {
        fetchTodoList(from: fromIndex, to: toIndex)
        fetchCategoryList()
    }
    
    func fetchTodoList(from fromIndex: Int, to toIndex: Int) {

        guard let currentDate = try? self.currentDate.value(),
              let groupId,
              let memberId = member?.memberId else { return }
        
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
                return self.fetchMemberTodoUseCase
                    .execute(
                        token: token,
                        groupId: groupId,
                        memberId: memberId,
                        from: fromMonthStart,
                        to: toMonthStart
                    )
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
    
    func fetchCategoryList() {
        guard let groupId,
              let memberId = member?.memberId else { return }
        
        let fetchMemberCategoryUseCase = fetchMemberCategoryUseCase
        
        getTokenUseCase
            .execute()
            .flatMap { token -> Single<[Category]> in
                fetchMemberCategoryUseCase
                    .execute(token: token, groupId: groupId, memberId: memberId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.categoryDict.removeAll()
                list.forEach {
                    guard let id = $0.id else { return }
                    self?.categoryDict[id] = $0
                }
                self?.categoryFetched.onNext(())
            })
            .disposed(by: bag)
    }
    
    func getMaxInWeek(indexPath: IndexPath) -> DayViewModel {
        let item = indexPath.item
        let section = indexPath.section
        
        let maxItem = ((item-item%7)..<(item+7-item%7)).max(by: { (a,b) in
            mainDayList[section][a].todoList.count < mainDayList[section][b].todoList.count
        }) ?? Int()
        
        return mainDayList[indexPath.section][maxItem]
    }
    
    func fetchImage(key: String) -> Single<Data> {
        fetchImageUseCase
            .execute(key: key)
    }
}

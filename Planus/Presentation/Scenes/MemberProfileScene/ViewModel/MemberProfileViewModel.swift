//
//  MemberProfileViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import Foundation
import RxSwift

class MemberProfileViewModel: ViewModel {
    
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

    var mainDayList = [[Day]]()
    var todos = [Date: [SocialTodoSummary]]()
    
    var blockMemo = [[Int?]](repeating: [Int?](repeating: nil, count: 30), count: 42) //todoId
    
    var filteredWeeksOfYear = [Int](repeating: -1, count: 6)
    var filteredTodoCache = [FilteredSocialTodoViewModel](repeating: FilteredSocialTodoViewModel(periodTodo: [], singleTodo: []), count: 42)
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
                        date: vm.mainDayList[indexPath.section][indexPath.item].date
                    )
                )
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
    
    func updateTitle(date: Date) {
        currentYYYYMM.onNext(useCases.dateFormatYYYYMMUseCase.execute(date: date))
    }
    
    func initCalendar(date: Date) {
        mainDayList = (endOfFirstIndex...endOfLastIndex).map { difference -> [Day] in
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
        let toIndex = currentIndex + cachingAmount + 1 < mainDayList.count ? currentIndex + cachingAmount + 1 : mainDayList.count-1
        
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

//
//  HomeViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

enum ScrollDirection {
    case left
    case none
    case right
}

class HomeCalendarViewModel {
    
    var bag = DisposeBag()
        
    let calendar = Calendar.current
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        return dateFormatter
    }()
    
    lazy var currentDate = BehaviorSubject<Date?>(value: nil)
    var currentYearMonth = BehaviorSubject<String?>(value: nil)

    var days = [[DayViewModel]]()

    var initDaysLoaded = BehaviorSubject<Int?>(value: nil) //뷰컨과 바인딩 전에 init될 수 있으므로
    var followingDaysLoaded = PublishSubject<Int>()
    var prevDaysLoaded = PublishSubject<Int>()
    
    let cachingIndexDiff = 2
    let halfOfInitAmount = 5
    
    lazy var currentIndex: Int = {
        return self.halfOfInitAmount
    }()
        
    var todo = [Date: Todo]()
    
    var prevCache = [[DayViewModel]]()
    var followingCache = [[DayViewModel]]()
    
    struct Input {
        var didScrollTo: Observable<ScrollDirection>
        var viewDidLoaded: Observable<Void>
    }
        
    struct Output {
        var didLoadYearMonth: Observable<String?>
        var initDaysLoaded: Observable<Int?> //아에 월별로 이동할땐 이걸 사용(전체 데이터소스를 초기화)
        var prevDaysLoaded: Observable<Int> //스크롤로 이동할 땐 이걸 사용하자, 일정 인덱스에 도달하면 앞에 추가
        var followingDaysLoaded: Observable<Int> //스크롤로 이동할 땐 이걸 사용하자, 일정 인덱스에 도달하면 뒤에 추가
    }
    
    let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
    let fetchTodoListUseCase: FetchTodoListUseCase
    
    init(
        createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase,
        fetchTodoListUseCase: FetchTodoListUseCase
    ) {
        self.createMonthlyCalendarUseCase = createMonthlyCalendarUseCase
        self.fetchTodoListUseCase = fetchTodoListUseCase
        bind()
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
        
        input.viewDidLoaded
            .subscribe { [weak self] in
                let components = self?.calendar.dateComponents(
                    [.year, .month],
                    from: Date()
                ) ?? DateComponents()
                
                let currentDate = self?.calendar.date(from: components) ?? Date()
                self?.currentDate.onNext(currentDate)
                self?.initCalendar(date: currentDate)
            }
            .disposed(by: bag)
        
        input
            .didScrollTo
            .subscribe { [weak self] direction in

            }
            .disposed(by: bag)
        
        
        return Output(
            didLoadYearMonth: currentYearMonth.asObservable(),
            initDaysLoaded: initDaysLoaded.asObservable(),
            prevDaysLoaded: prevDaysLoaded.asObservable(),
            followingDaysLoaded: followingDaysLoaded.asObservable()
        )
    }
    
    func updateTitle(date: Date) {
        currentYearMonth.onNext(self.dateFormatter.string(from: date))
    }

    func initCalendar(date: Date) {
        days = (-halfOfInitAmount...halfOfInitAmount).map { i -> [DayViewModel] in
            let calendarDate = self.calendar.date(byAdding: DateComponents(month: i), to: date) ?? Date()
            return createMonthlyCalendarUseCase.execute(date: calendarDate).map {
                var dayViewModel = $0
                dayViewModel.todoList = fetchTodoListUseCase.execute(date: $0.date)
                return dayViewModel
            }
        }
        initDaysLoaded.onNext(days.count)
    }
    
    func updateCurrentDate(direction: ScrollDirection) {
        guard let previousDate = try? self.currentDate.value() else { return }
        // 우선 인덱스가 바뀜, 그다음에 인덱스에 대해 계산해야함
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

    func scrolledTo(direction: ScrollDirection) { // 일정 부분까지 오면 받아서 캐싱해뒀다가 마지막 인덱스를 탁 쳤을때 더하고 보여주기?
        updateCurrentDate(direction: direction)
        checkCacheLoadNeed()
        checkCacheFetchNeed() // 여기 이후는 캐시가 있을때만 진행되야함. 그전까진 페치해주면 안됨! 캐시없으면 스크롤 못하는거임!
    }
    
    func checkCacheLoadNeed() {
        guard let currentDate = try? self.currentDate.value() else { return }
        if currentIndex <= cachingIndexDiff && prevCache.isEmpty {
            let amountToMake = halfOfInitAmount + currentIndex - cachingIndexDiff
            self.prevCache = additionalMonthlyCalendars(date: currentDate, difference: 0 - currentIndex, amount: amountToMake)
        } else if currentIndex >= days.count-1 - cachingIndexDiff && followingCache.isEmpty {
            let amountToMake = halfOfInitAmount - (days.count - 1 - currentIndex) + cachingIndexDiff
            self.followingCache = additionalMonthlyCalendars(date: currentDate, difference: days.count - 1 - currentIndex, amount: amountToMake)
        }
    }
    
    func checkCacheFetchNeed() {
        if currentIndex == 0 {
            days = prevCache + days[0..<days.count - prevCache.count]
            currentIndex = currentIndex + prevCache.count
            prevDaysLoaded.onNext(prevCache.count)
            
            prevCache.removeAll()
            followingCache.removeAll()
        } else if currentIndex == days.count - 1 {
            days = days[followingCache.count..<days.count] + followingCache
            currentIndex = currentIndex - followingCache.count
            followingDaysLoaded.onNext(followingCache.count)
            
            prevCache.removeAll()
            followingCache.removeAll()
        }
    }
    
    func additionalMonthlyCalendars(date: Date, difference diff: Int, amount: Int) -> [[DayViewModel]] {

        var range = Array(1...amount)
        if diff < 0 {
            range = range.reversed().map { -$0 }
        }
        
        return range.map { $0 + diff }.map { i in
            let calendarDate = self.calendar.date(byAdding: DateComponents(month: i), to: date) ?? Date()
            return createMonthlyCalendarUseCase.execute(date: calendarDate).map {
                var dayViewModel = $0
                dayViewModel.todoList = fetchTodoListUseCase.execute(date: $0.date)
                return dayViewModel
            }
        }
    }
}


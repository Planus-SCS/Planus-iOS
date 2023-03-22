//
//  HomeViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

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
        var scrollDidDeceleratedWithDoubleIndex: Observable<Double>
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
            .scrollDidDeceleratedWithDoubleIndex
            .subscribe { [weak self] offset in
                var newIndex: Int

                if Double(self!.currentIndex) < offset {
                    // 우슬라이드 시, 다음페이지를 찍자마자 갱신해야함(만약 정확한 정수만큼의 offset을 지나쳐도 해당 정수만큼 내림됨
                    newIndex = Int(floor(offset))
                } else if Double(self!.currentIndex) > offset {
                    // 좌 슬라이드 시, 이전 페이지를 찍자마자 갱신(정확한 정수를 지나쳐도 해당 정수로 올림됨
                    newIndex = Int(ceil(offset))
                } else {
                    return
                }
                if newIndex != self?.currentIndex {
                    self?.scrolledTo(index: newIndex)
                }
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

    func initCalendar(date: Date){
        var fullCalendar = [[DayViewModel]]()
        
        (-halfOfInitAmount...halfOfInitAmount).forEach { i in
            let calendarDate = self.calendar.date(byAdding: DateComponents(month: i), to: date) ?? Date()
            fullCalendar.append(createMonthlyCalendarUseCase.execute(date: calendarDate).map {
                var dayViewModel = $0
                dayViewModel.todoList = fetchTodoListUseCase.execute(date: $0.date)
                return dayViewModel
            })
        }
        
        days = fullCalendar
        initDaysLoaded.onNext(fullCalendar.count)
    }
    
    func scrolledTo(index: Int) { // 일정 부분까지 오면 받아서 캐싱해뒀다가 마지막 인덱스를 탁 쳤을때 더하고 보여주기?
        let diff = index - currentIndex

        guard let previousDate = try? self.currentDate.value(),
              let currentDate = self.calendar.date(
                byAdding: DateComponents(month: diff),
                to: previousDate
        ) else { return }
        
        self.currentIndex = index
        self.currentDate.onNext(currentDate)
        
        
        if index <= cachingIndexDiff && prevCache.isEmpty {
            let amountToMake = halfOfInitAmount + index - cachingIndexDiff
            self.prevCache = additionalMonthlyCalendars(date: currentDate, index: index, endIndex: 0, amount: amountToMake)
            
        } else if index >= days.count-1 - cachingIndexDiff && followingCache.isEmpty {
            let amountToMake = halfOfInitAmount - (days.count - 1 - index) + cachingIndexDiff
            self.followingCache = additionalMonthlyCalendars(date: currentDate, index: index, endIndex: days.count - 1, amount: amountToMake)
            
        }
        
        if index == 0 {
            days = prevCache + days[0..<days.count - prevCache.count]
            currentIndex = currentIndex + prevCache.count
            prevDaysLoaded.onNext(prevCache.count)
            
            prevCache.removeAll()
            followingCache.removeAll()
        } else if index == days.count - 1 {
            days = days[followingCache.count..<days.count] + followingCache
            currentIndex = currentIndex - followingCache.count
            followingDaysLoaded.onNext(followingCache.count)
            
            prevCache.removeAll()
            followingCache.removeAll()
        }
        
    }
    
    func additionalMonthlyCalendars(date: Date, index: Int, endIndex: Int, amount: Int) -> [[DayViewModel]] {
        var additionalCalendar = [[DayViewModel]]()
        if (index < endIndex) {
            let diff = endIndex - index
            (1...amount).forEach {
                let calendarDate = self.calendar.date(byAdding: DateComponents(month: $0+diff), to: date) ?? Date()
                let dayList = createMonthlyCalendarUseCase.execute(date: calendarDate).map {
                    var dayViewModel = $0
                    dayViewModel.todoList = fetchTodoListUseCase.execute(date: $0.date)
                    return dayViewModel
                }
                additionalCalendar.append(dayList)
            }
        } else {
            let diff = index - endIndex
            (-amount..<0).forEach {
                let calendarDate = self.calendar.date(byAdding: DateComponents(month: $0-diff), to: date) ?? Date()
                let dayList = createMonthlyCalendarUseCase.execute(date: calendarDate).map {
                    var dayViewModel = $0
                    dayViewModel.todoList = fetchTodoListUseCase.execute(date: $0.date)
                    return dayViewModel
                }
                additionalCalendar.append(dayList)
            }
        }
        return additionalCalendar
    }
    
//    func test() -> [[DayViewModel]] {
//
//    }
}


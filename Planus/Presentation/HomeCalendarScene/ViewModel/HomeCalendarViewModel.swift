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
    
    // for todoList caching
    let cachingIndexDiff = 3
    let cachingAmount = 5
    
    let endOfFirstIndex = -100
    let endOfLastIndex = 1000
    
    var latestPrevCacheRequestedIndex = 0
    var latestFollowingCacheRequestedIndex = 0
    
    var currentDate = BehaviorSubject<Date?>(value: nil)
    var currentYYYYMM = BehaviorSubject<String?>(value: nil)

    var mainDayList = [[DayViewModel]]()

    var initialDayListFetchedInCenterIndex = BehaviorSubject<Int?>(value: nil)
    var todoListFetchedInIndexRange = BehaviorSubject<(Int, Int)?>(value: nil)
    
    var currentIndex = Int()
    
    struct Input {
        var didScrollTo: Observable<ScrollDirection>
        var viewDidLoaded: Observable<Void>
    }
    
    struct Output {
        var didLoadYYYYMM: Observable<String?>
        var initialDayListFetchedInCenterIndex: Observable<Int?>
        var todoListFetchedInIndexRange: Observable<(Int, Int)?> // a부터 b까지 리로드 해라!
    }
    
    let createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase
    let fetchTodoListUseCase: FetchTodoListUseCase
    let dateFormatYYYYMMUseCase: DateFormatYYYYMMUseCase
    
    init(
        createMonthlyCalendarUseCase: CreateMonthlyCalendarUseCase,
        fetchTodoListUseCase: FetchTodoListUseCase,
        dateFormatYYYYMMUseCase: DateFormatYYYYMMUseCase
    ) {
        self.createMonthlyCalendarUseCase = createMonthlyCalendarUseCase
        self.fetchTodoListUseCase = fetchTodoListUseCase
        self.dateFormatYYYYMMUseCase = dateFormatYYYYMMUseCase
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
            .withUnretained(self)
            .subscribe { vm, _ in
                let components = vm.calendar.dateComponents(
                    [.year, .month],
                    from: Date()
                )
                
                let currentDate = vm.calendar.date(from: components) ?? Date()
                vm.currentDate.onNext(currentDate)
                vm.initCalendar(date: currentDate)
                vm.initTodoList(date: currentDate)
            }
            .disposed(by: bag)
        
        input
            .didScrollTo
            .withUnretained(self)
            .subscribe { vm, direction in
                vm.scrolledTo(direction: direction)
            }
            .disposed(by: bag)
        
        return Output(
            didLoadYYYYMM: currentYYYYMM.asObservable(),
            initialDayListFetchedInCenterIndex: initialDayListFetchedInCenterIndex.asObservable(),
            todoListFetchedInIndexRange: todoListFetchedInIndexRange.asObservable()
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
        let fromIndex = currentIndex - cachingAmount
        let toIndex = currentIndex + cachingAmount
        
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
    
    // 미리 앞부분을 캐시를 로드해버리자
    func checkCacheLoadNeed() {
        guard let currentDate = try? self.currentDate.value() else { return }
        if latestPrevCacheRequestedIndex - currentIndex == cachingIndexDiff {
            latestPrevCacheRequestedIndex = currentIndex

            let fromIndex = currentIndex - cachingAmount - (cachingAmount - cachingIndexDiff)
            let toIndex = currentIndex - (cachingAmount - cachingIndexDiff)
            fetchTodoList(from: fromIndex, to: toIndex)
            
        } else if currentIndex - latestFollowingCacheRequestedIndex == cachingIndexDiff {
            latestFollowingCacheRequestedIndex = currentIndex
            let fromIndex = currentIndex + cachingIndexDiff
            let toIndex = currentIndex + cachingIndexDiff + cachingAmount
            
            fetchTodoList(from: fromIndex, to: toIndex)
        }
    }
    
    func fetchTodoList(from fromIndex: Int, to toIndex: Int) {
        guard let currentDate = try? self.currentDate.value() else { return }
        let fromMonth = calendar.date(byAdding: DateComponents(month: fromIndex - currentIndex), to: currentDate) ?? Date()
        let toMonth = calendar.date(byAdding: DateComponents(month: toIndex - currentIndex), to: currentDate) ?? Date()
        
        let fromMonthStart = calendar.startOfDay(for: fromMonth)
        let toMonthStart = calendar.startOfDay(for: toMonth)

        fetchTodoListUseCase.execute(from: fromMonthStart, to: toMonthStart)
            .subscribe(onSuccess: { [weak self] todoDict in
                guard let self else { return }
                (fromIndex..<toIndex).forEach { index in
                    self.mainDayList[index] = self.mainDayList[index].map {
                        var dayViewModel = $0
                        dayViewModel.todoList = todoDict[$0.date]
                        return dayViewModel
                    }
                }
                self.todoListFetchedInIndexRange.onNext((fromIndex, toIndex))
            })
            .disposed(by: bag)
    }
}


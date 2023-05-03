//
//  TodoMainViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import Foundation
import RxSwift

class TodoMainViewModel {
    
    var bag = DisposeBag()
        
    let calendar = Calendar.current
    
    // for todoList caching
    let cachingIndexDiff = 8
    let cachingAmount = 10
    
    let diffWithFirstMonth = -100
    let diffWithLastMonth = 500
    
    var latestPrevCacheRequestedIndex = 0
    var latestFollowingCacheRequestedIndex = 0
    
    var currentDate = BehaviorSubject<Date?>(value: nil)
    var currentYYYYMMDD = BehaviorSubject<String?>(value: nil)
    
    var currentIndex = 0

    var mainDayList = [DetailDayViewModel]() //이건 살짝 다르게 가져가도 됨. 아니

    var initialDayListFetchedInCenterIndex = BehaviorSubject<Int?>(value: nil)
    var todoListFetchedInIndexRange = BehaviorSubject<(Int, Int)?>(value: nil)
    var showTodoDetailPage = PublishSubject<DayViewModel>()
    var showDayPicker = PublishSubject<Void>()
    var dayChangedByPicker = PublishSubject<Date>()
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter
    }()
    
    
    struct Input {
        var didSelectItem: Observable<IndexPath>
        var didTappedTitleButton: Observable<Void>
        var didSelectDay: Observable<Date>
    }
    
    struct Output {
        var didLoadYYYYMMDD: Observable<String?> // currentYYYYMMDD
        var initialDayListFetchedInCenterIndex: Observable<Int?> //initailDayListFetchedInCenterIndex
        var todoListFetchedInIndexRange: Observable<(Int, Int)?> //todoListFetchedInIndexRange
        var showTodoDetailPage: Observable<DayViewModel> //
        var showDayPicker: Observable<Void> //앞 현재 끝
        var dayChangedByPicker: Observable<Date> //인덱스만 알려주자!
    }
    
    let fetchTodoListUseCase: ReadTodoListUseCase
    let createDailyCalendarUseCase: CreateDailyCalendarUseCase
    
    init(
        fetchTodoListUseCase: ReadTodoListUseCase,
        createDailyCalendarUseCase: CreateDailyCalendarUseCase
    ) {
        self.fetchTodoListUseCase = fetchTodoListUseCase
        self.createDailyCalendarUseCase = createDailyCalendarUseCase
        bind()
        
        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        
        let currentDate = calendar.date(from: components) ?? Date()
        DispatchQueue.global().async {
            self.currentDate.onNext(currentDate)
            self.initCalendar(date: currentDate)
            self.initTodoList(date: currentDate)
        }

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
//
//        input.viewDidLoaded
//            .withUnretained(self)
//            .subscribe { vm, _ in
//                let components = vm.calendar.dateComponents(
//                    [.year, .month, .day],
//                    from: Date()
//                )
//
//                let currentDate = vm.calendar.date(from: components) ?? Date()
//                vm.currentDate.onNext(currentDate)
//                vm.initCalendar(date: currentDate)
//                vm.initTodoList(date: currentDate)
//            }
//            .disposed(by: bag)
        
//        input
//            .didScrollTo
//            .withUnretained(self)
//            .subscribe { vm, direction in
//                vm.scrolledTo(direction: direction)
//            }
//            .disposed(by: bag)
        
        input
            .didSelectItem
            .withUnretained(self)
            .subscribe { vm, index in
            }
            .disposed(by: bag)
        
        input
            .didTappedTitleButton
            .withUnretained(self)
            .subscribe { vm, _ in
//                guard let currentDate = try? vm.currentDate.value() else { return }
//                let first = vm.mainDayList[0][7].date
//                let last = vm.mainDayList[vm.mainDayList.count-1][7].date
//                vm.showMonthPicker.onNext((first, currentDate, last))
            }
            .disposed(by: bag)
        
        input.didSelectDay
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vm, date in
//                let start = vm.mainDayList[0].date
//                let index = vm.calendar.dateComponents([.month], from: vm.calendar.startDayOfMonth(date: start), to: date).month ?? 0
//                print(index)
//                vm.currentIndex = index
//                vm.currentDate.onNext(date)
//                vm.didSelectMonth.onNext(index)
//                vm.initTodoList(date: date)
//                print(date)
            })
            .disposed(by: bag)
        
        return Output(
            didLoadYYYYMMDD: currentYYYYMMDD.asObservable(),
            initialDayListFetchedInCenterIndex: initialDayListFetchedInCenterIndex.asObservable(),
            todoListFetchedInIndexRange: todoListFetchedInIndexRange.asObservable(),
            showTodoDetailPage: showTodoDetailPage.asObservable(),
            showDayPicker: showDayPicker.asObservable(),
            dayChangedByPicker: dayChangedByPicker.asObservable()
        )
        
    }
    
    func updateTitle(date: Date) {
        currentYYYYMMDD.onNext(dateFormatter.string(from: date))
    }
    
    // 여기서 일단 싸악 다 만들어두자
    func initCalendar(date: Date) {
        
        let firstDate = calendar.date(byAdding: DateComponents(month: diffWithFirstMonth), to: date) ?? Date()
        let lastDate = calendar.date(byAdding: DateComponents(month: diffWithLastMonth+1), to: date) ?? Date()
        self.mainDayList = createDailyCalendarUseCase.execute(from: firstDate, to: lastDate)

        currentIndex = calendar.dateComponents([.day], from: firstDate, to: date).day ?? Int()
        
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
                                byAdding: DateComponents(day: -1),
                                to: previousDate
                        ))
            currentIndex-=1
        case .right:
            currentDate.onNext(self.calendar.date(
                                byAdding: DateComponents(day: 1),
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
            print("from: \(fromIndex), to: \(toIndex), current: \(currentIndex)")
            fetchTodoList(from: fromIndex, to: toIndex)
            
            // 100에서 시작함 108에 도달함. 리로드 실시하고 어디부터 어디까지? 111 - 118 까지
            // 108에서 리로드를 했음. 현재는 119까지 있음. 그럼 이제 또 116에서 리로드가 이뤄지겠지?
        } else if currentIndex - latestFollowingCacheRequestedIndex == cachingIndexDiff {
            latestFollowingCacheRequestedIndex = currentIndex
            let fromIndex = currentIndex + cachingAmount - cachingIndexDiff + 1 // 108 + 10 - 8 + 1
            let toIndex = currentIndex + cachingAmount + 1 // 108 + 10
            print("current: \(currentIndex), from: \(fromIndex), to: \(toIndex)")
            fetchTodoList(from: fromIndex, to: toIndex)
        }
    }
    
    func fetchTodoList(from fromIndex: Int, to toIndex: Int) {
//
//        guard let currentDate = try? self.currentDate.value() else { return }
//        let fromDay = calendar.date(byAdding: DateComponents(day: fromIndex - currentIndex), to: currentDate) ?? Date()
//        let toDay = calendar.date(byAdding: DateComponents(day: toIndex - currentIndex), to: currentDate) ?? Date()
//
//        fetchTodoListUseCase.execute(from: fromDay, to: toDay)
//            .subscribe(onSuccess: { [weak self] todoDict in
//                guard let self else { return }
//                (fromIndex..<toIndex).forEach { index in
//                    var detailDayViewModel = self.mainDayList[index]
//                    if let list = todoDict[detailDayViewModel.date] {
//                        detailDayViewModel.scheduledTodoList = list.filter { $0.startTime != nil }
//                        detailDayViewModel.unSchedultedTodoList = list.filter { $0.startTime == nil }
//                    }
//                    self.mainDayList[index] = detailDayViewModel
//                }
//                self.todoListFetchedInIndexRange.onNext((fromIndex, toIndex))
//            })
//            .disposed(by: bag)
    }
}

//
//  SmallCalendarViewModel.swift
//  calendarTest
//
//  Created by Sangmin Lee on 2023/03/20.
//

import Foundation
import RxSwift

final class SmallCalendarViewModel {
    var bag = DisposeBag()
        
    let calendar = Calendar.current
    
    var completionHandler: ((Date) -> Void)?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        return dateFormatter
    }()
    
    var minDate: Date?
    var maxDate: Date?
    
    var currentMonth = BehaviorSubject<Date?>(value: nil)
    var currentDate: Date?
    var currentDateLabel = BehaviorSubject<String?>(value: nil)

    var days = [[SmallCalendarDayViewModel]]()
    var prevCachedDays = [[SmallCalendarDayViewModel]]()
    var followingCachedDays = [[SmallCalendarDayViewModel]]()
    
    var initDaysLoaded = BehaviorSubject<Int?>(value: nil) //뷰컨과 바인딩 전에 init될 수 있으므로
    var followingDaysLoaded = PublishSubject<Int>()
    var prevDaysLoaded = PublishSubject<Int>()
    var shouldDismiss = PublishSubject<Void>()
    
    let cachingIndexDiff = 2
    let halfOfInitAmount = 5
    
    lazy var currentIndex = halfOfInitAmount
    
    struct Input {
        var didLoadView: Observable<Void>
        var didSelectAt: Observable<IndexPath>
        var didChangedIndex: Observable<Double>
    }
    
    struct Output {
        var didLoadInitDays: Observable<Int?>
        var didLoadFollowingDays: Observable<Int>
        var didLoadPrevDays: Observable<Int>
        var didChangedTitleLabel: Observable<String?>
        var shouldDismiss: Observable<Void>
    }
    
    init() {
        self.bind()
    }
    
    func configureDate(currentDate: Date, min: Date, max: Date) {
        self.currentDate = currentDate
        self.minDate = min
        self.maxDate = max
        let components = self.calendar.dateComponents(
            [.year, .month],
            from: currentDate
        ) ?? DateComponents()
        
        let currentDate = self.calendar.date(from: components) ?? Date()
        self.currentMonth.onNext(currentDate)
    }
    
    private func bind() {
        currentMonth
            .compactMap { $0 }
            .single()
            .withUnretained(self)
            .subscribe { vm, date in
                vm.initCalendar(date: date)
            }
            .disposed(by: bag)
        
        currentMonth
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vm, date in
                let dateString = vm.dateFormatter.string(from: date)
                vm.currentDateLabel.onNext(dateString)
            })
            .disposed(by: bag)
    }
    
    public func transform(input: Input) -> Output {
        input
            .didChangedIndex
            .withUnretained(self)
            .subscribe(onNext: { [weak self] vm, doubleIndex in
                let prevIndex = Double(vm.currentIndex)
                guard doubleIndex != prevIndex else { return }
                
                let intIndex = Int(doubleIndex < prevIndex ? ceil(doubleIndex) : floor(doubleIndex))
                self?.scrolledTo(index: intIndex)
            })
            .disposed(by: bag)
        
        input
            .didSelectAt
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                let date = vm.days[indexPath.section][indexPath.row].date
                vm.completionHandler?(date)
                vm.shouldDismiss.onNext(())
            })
            .disposed(by: bag)
        
        return Output(
            didLoadInitDays: initDaysLoaded.asObservable(),
            didLoadFollowingDays: followingDaysLoaded.asObservable(),
            didLoadPrevDays: prevDaysLoaded.asObservable(),
            didChangedTitleLabel: currentDateLabel.asObservable(),
            shouldDismiss: shouldDismiss.asObservable()
        )
    }

    private func monthlyCalendar(date: Date, diff: Int) -> [SmallCalendarDayViewModel] {
        let calendarDate = self.calendar.date(byAdding: DateComponents(month: diff), to: date) ?? Date()
        let indexOfCurrentStart = (self.calendar.startDayOfTheWeek(from: calendarDate) + 7 - 1)%7 //기준달의 시작 요일
        let indexOfFollowingStart = indexOfCurrentStart + self.calendar.endDateOfMonth(for: calendarDate) // 다음달의 시작 인덱스
        let totalDaysToShow = indexOfFollowingStart + ((indexOfFollowingStart % 7 == 0) ? 0 : (7 - indexOfFollowingStart % 7)) //총 포문 돌 갯수

        var startDayOfMonth = self.calendar.startDayOfMonth(date: calendarDate)

        var dayList = [SmallCalendarDayViewModel]()
        for day in Int()..<totalDaysToShow {
            var date: Date
            var state: MonthStateOfDay
            
            switch day {
            case (0..<indexOfCurrentStart):
                date = calendar.date(byAdding: DateComponents(day: -indexOfCurrentStart + day), to: startDayOfMonth) ?? Date()
                state = .prev
            case (indexOfCurrentStart..<indexOfFollowingStart):
                date = calendar.date(byAdding: DateComponents(day: day - indexOfCurrentStart), to: startDayOfMonth) ?? Date()
                state = .current
            case (indexOfFollowingStart..<totalDaysToShow):
                date = calendar.date(byAdding: DateComponents(day: day - indexOfCurrentStart), to: startDayOfMonth) ?? Date()
                state = .following
            default:
                fatalError()
            }
            
            dayList.append(
                SmallCalendarDayViewModel(
                    dayLabel: "\(calendar.component(.day, from: date))",
                    date: date,
                    state: state
                )
            )
        }
        
        return dayList
    }

    private func initCalendar(date: Date) {
        var fullCalendar = [[SmallCalendarDayViewModel]]()
        
        (-halfOfInitAmount...halfOfInitAmount).forEach { i in
            fullCalendar.append(monthlyCalendar(date: date, diff: i))
        }
        
        days = fullCalendar
        initDaysLoaded.onNext(fullCalendar.count)
    }
    
    private func scrolledTo(index: Int) { // 일정 부분까지 오면 받아서 캐싱해뒀다가 마지막 인덱스를 탁 쳤을때 더하고 보여주기?
        let diff = index - currentIndex

        guard let previousDate = try? self.currentMonth.value(),
              let currentDate = self.calendar.date(
                byAdding: DateComponents(month: diff),
                to: previousDate
        ) else { return }
        
        self.currentIndex = index
        self.currentMonth.onNext(currentDate)
        
        if index <= cachingIndexDiff && prevCachedDays.isEmpty {
            let endIndex = 0
            let amountToMake = halfOfInitAmount + index - cachingIndexDiff
            self.prevCachedDays = additionalMonthlyCalendars(date: currentDate, diff: endIndex - index, amount: amountToMake)
        } else if index >= days.count-1 - cachingIndexDiff && followingCachedDays.isEmpty {
            let endIndex = days.count - 1
            let amountToMake = halfOfInitAmount - (days.count - 1 - index) + cachingIndexDiff
            self.followingCachedDays = additionalMonthlyCalendars(date: currentDate, diff: endIndex - index, amount: amountToMake)
        }
                
        if index == 0 {
            addPrevCachedDataDays()
        } else if index == days.count - 1 {
            addFollowingCachedDays()
        }
        
    }
    
    private func addPrevCachedDataDays() {
        days = prevCachedDays + days[0..<days.count - prevCachedDays.count]
        currentIndex = currentIndex + prevCachedDays.count
        prevDaysLoaded.onNext(prevCachedDays.count)
        
        prevCachedDays.removeAll()
        followingCachedDays.removeAll()
    }
    
    private func addFollowingCachedDays() {
        days = days[followingCachedDays.count..<days.count] + followingCachedDays
        currentIndex = currentIndex - followingCachedDays.count
        followingDaysLoaded.onNext(followingCachedDays.count)
        
        prevCachedDays.removeAll()
        followingCachedDays.removeAll()
    }
    
    private func additionalMonthlyCalendars(date: Date, diff: Int, amount: Int) -> [[SmallCalendarDayViewModel]] {
        var additionalCalendar = [[SmallCalendarDayViewModel]]()
        
        let range = (1...amount).map {
            return (diff > 0) ? $0 : $0-amount-1
        }
        range.forEach {
            additionalCalendar.append(monthlyCalendar(date: date, diff: $0+diff))
        }
        return additionalCalendar
    }
}

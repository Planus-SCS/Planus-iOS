//
//  DayPickerViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

class DayPickerViewController: UIViewController {
    
    weak var delegate: DayPickerViewControllerDelegate?
    
    let calendar = Calendar.current
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        return dateFormatter
    }()
    
    lazy var dateFormatter2: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter
    }()
    
    var firstSelectedIndexPath: IndexPath?
    var secondSelectedIndexPath: IndexPath?
    
    var currentMonth: Date?
    var currentDateLabel: String?

    // MARK: Main Calendar Of Picker
    /// days: dataSource로 사용될 메인 달력
    var days = [[DayPickerModel]]()
    
    
    // MARK: Cache that storing Previously fetched Calendar
    /// prevCachedDays: 좌측 달력 용 캐시
    /// followingCachedDays: 우측 달력용 캐시
    var prevCachedDays = [[DayPickerModel]]()
    var followingCachedDays = [[DayPickerModel]]()
    
    
    // MARK: Caching Constraints
    /// cachingIndexDiff: endIndex 에 도달하기 전에 미리 캐싱을 시작할 인덱스 차이
    /// halfOfInitAmount: 캘린더 초기화 시 생성할 캘린더 달의 개수, 캐싱 시에도 해당 amount 만큼 달력 fetch
    let cachingIndexDiff = 2
    let halfOfInitAmount = 5
    
    lazy var currentIndex = halfOfInitAmount
    
    var dayPickerView: DayPickerView?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        let view = DayPickerView(frame: self.view.frame)
        self.view = view
        dayPickerView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayPickerView?.dayPickerCollectionView.dataSource = self
        dayPickerView?.dayPickerCollectionView.delegate = self
                
        dayPickerView?.prevButton.addTarget(self, action: #selector(prevBtnTapped), for: .touchUpInside)
        dayPickerView?.nextButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
    }
    
    public func setDate(date: Date) {
        let components = self.calendar.dateComponents(
            [.year, .month],
            from: date
        )
        
        let currentMonth = self.calendar.date(from: components) ?? Date()
        self.currentMonth = currentMonth
        
        initCalendar(date: currentMonth)
        updateTitle(date: currentMonth)
        
        let frameWidth = UIScreen.main.bounds.width - 20
        self.reloadAndMove(to: CGPoint(x: frameWidth * CGFloat(halfOfInitAmount), y: 0))
        
        guard let dateIndex = days[halfOfInitAmount].firstIndex(where: { $0.date == date }) else { return }
        
        self.collectionView(dayPickerView?.dayPickerCollectionView ?? UICollectionView(), didSelectItemAt: IndexPath(item: dateIndex, section: halfOfInitAmount))

    }
    
    public func selectDate(date: Date) {
        days.enumerated().forEach { monthIndex, daysPerMonth in
            daysPerMonth.enumerated().forEach { dayIndex, day in
                if day.date == date {
                    self.dayPickerView?.dayPickerCollectionView.selectItem(at: IndexPath(item: dayIndex, section: monthIndex), animated: false, scrollPosition: .top)
                }
            }
        }
    }
    
    private func updateTitle(date: Date) {
        let dateString = dateFormatter.string(from: date)
        dayPickerView?.dateLabel.text = dateString
    }

    private func initCalendar(date: Date) {
        var fullCalendar = [[DayPickerModel]]()
        
        (-halfOfInitAmount...halfOfInitAmount).forEach { i in
            fullCalendar.append(monthlyCalendar(date: date, diff: i))
        }
        
        days = fullCalendar

    }
    
    private func reloadAndMove(to point: CGPoint) {
        dayPickerView?.dayPickerCollectionView.reloadData()
        dayPickerView?.dayPickerCollectionView.performBatchUpdates {
            dayPickerView?.dayPickerCollectionView.setContentOffset(
                point,
                animated: false
            )
        }
    }
    
    internal func scrolledTo(index: Int) { // 일정 부분까지 오면 받아서 캐싱해뒀다가 마지막 인덱스를 탁 쳤을때 더하고 보여주기?
        let diff = index - currentIndex

        guard let previousDate = currentMonth,
              let currentMonth = self.calendar.date(
                byAdding: DateComponents(month: diff),
                to: previousDate
        ) else { return }
        
        self.currentIndex = index
        self.currentMonth = currentMonth
        updateTitle(date: currentMonth)
        
        if index <= cachingIndexDiff && prevCachedDays.isEmpty {
            let endIndex = 0
            let amountToMake = halfOfInitAmount + index - cachingIndexDiff
            self.prevCachedDays = additionalMonthlyCalendars(date: currentMonth, diff: endIndex - index, amount: amountToMake)
        } else if index >= days.count-1 - cachingIndexDiff && followingCachedDays.isEmpty {
            let endIndex = days.count - 1
            let amountToMake = halfOfInitAmount - (days.count - 1 - index) + cachingIndexDiff
            self.followingCachedDays = additionalMonthlyCalendars(date: currentMonth, diff: endIndex - index, amount: amountToMake)
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
        
        let exPointX = dayPickerView?.dayPickerCollectionView.contentOffset.x ?? CGFloat()
        let frameWidth = self.view.frame.width
        reloadAndMove(to: CGPoint(x: exPointX + CGFloat(prevCachedDays.count)*frameWidth, y: 0))
        
        prevCachedDays.removeAll()
        followingCachedDays.removeAll()
    }
    
    private func addFollowingCachedDays() {
        days = days[followingCachedDays.count..<days.count] + followingCachedDays
        currentIndex = currentIndex - followingCachedDays.count
        
        let exPointX = dayPickerView?.dayPickerCollectionView.contentOffset.x ?? CGFloat()
        let frameWidth = self.view.frame.width
        reloadAndMove(to: CGPoint(x: exPointX - CGFloat(followingCachedDays.count)*frameWidth, y: 0))
        
        prevCachedDays.removeAll()
        followingCachedDays.removeAll()
    }
    
    private func additionalMonthlyCalendars(date: Date, diff: Int, amount: Int) -> [[DayPickerModel]] {
        var additionalCalendar = [[DayPickerModel]]()
        
        let range = (1...amount).map {
            return (amount > 0) ? $0 : $0-amount-1
        }
        range.forEach {
            additionalCalendar.append(monthlyCalendar(date: date, diff: $0+diff))
        }
        return additionalCalendar
    }
    
    private func monthlyCalendar(date: Date, diff: Int) -> [DayPickerModel] {
        let calendarDate = self.calendar.date(byAdding: DateComponents(month: diff), to: date) ?? Date()
        let indexOfCurrentStart = (self.calendar.startDayOfTheWeek(from: calendarDate) + 7 - 1)%7 //기준달의 시작 요일
        let indexOfFollowingStart = indexOfCurrentStart + self.calendar.endDateOfMonth(for: calendarDate) // 다음달의 시작 인덱스
        let totalDaysToShow = indexOfFollowingStart + ((indexOfFollowingStart % 7 == 0) ? 0 : (7 - indexOfFollowingStart % 7)) //총 포문 돌 갯수
        var startDayOfMonth = self.calendar.startDayOfMonth(date: calendarDate)
        
        var dayList = [DayPickerModel]()
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
                DayPickerModel(
                    dayLabel: "\(calendar.component(.day, from: date))",
                    date: date,
                    monthState: state,
                    rangeState: .none
                )
            )
        }
        return dayList
    }
}

extension DayPickerViewController {
    @objc func prevBtnTapped(_ sender: UIButton) {
        let exPointX = dayPickerView?.dayPickerCollectionView.contentOffset.x ?? CGFloat()
        let frameWidth = self.view.frame.width
        dayPickerView?.dayPickerCollectionView.setContentOffset(CGPoint(x: exPointX - frameWidth, y: 0), animated: true)
    }
    
    @objc func nextBtnTapped(_ sender: UIButton) {
        let exPointX = dayPickerView?.dayPickerCollectionView.contentOffset.x ?? CGFloat()
        let frameWidth = self.view.frame.width
        dayPickerView?.dayPickerCollectionView.setContentOffset(CGPoint(x: exPointX + frameWidth, y: 0), animated: true)
    }
}

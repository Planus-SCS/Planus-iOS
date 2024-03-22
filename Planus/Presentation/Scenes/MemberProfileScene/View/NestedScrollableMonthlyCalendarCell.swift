//
//  MemberProfileMonthlyCalendarCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift

class NestedScrollableMonthlyCalendarCell: NestedScrollableCell {
    
    static let reuseIdentifier = "nested-scrollable-monthly-calendar-cell"
    
    var section: Int?
    var viewModel: MemberProfileViewModel?
    
    var isSingleSelected: PublishSubject<IndexPath>?
        
    var bag: DisposeBag?
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        collectionView.showsVerticalScrollIndicator = false
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.register(DailyCalendarCell.self, forCellWithReuseIdentifier: DailyCalendarCell.identifier)
    }
    
    func fill(section: Int, viewModel: MemberProfileViewModel?) {
        self.section = section
        self.viewModel = viewModel
        collectionView.reloadData()
    }
    
    func fill(
        isSingleSelected: PublishSubject<IndexPath>
    ) {
        self.isSingleSelected = isSingleSelected
    }
}

extension NestedScrollableMonthlyCalendarCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = self.section else { return Int() }
        return viewModel?.mainDayList[section].count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section,
              let viewModel,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCell.identifier, for: indexPath) as? DailyCalendarCell else {
            return UICollectionViewCell()
        }
        
        let screenWidth = UIScreen.main.bounds.width
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let currentDate = viewModel.mainDayList[section][indexPath.item].date
        
        if viewModel.filteredWeeksOfYear[indexPath.item/7] != calendar.component(.weekOfYear, from: currentDate) {
            viewModel.filteredWeeksOfYear[indexPath.item/7] = calendar.component(.weekOfYear, from: currentDate) //애만 저장하면 위험함. 차라리 첫날을 저장하자
            (indexPath.item - indexPath.item%7..<indexPath.item - indexPath.item%7 + 7).forEach { //해당주차의 blockMemo를 전부 0으로 초기화
                viewModel.blockMemo[$0] = [Int?](repeating: nil, count: 20)
            }
            
            for (item, day) in Array(viewModel.mainDayList[section].enumerated())[indexPath.item - indexPath.item%7..<indexPath.item - indexPath.item%7 + 7] {
                var filteredTodoList = viewModel.todos[day.date] ?? []
                
                var periodList = filteredTodoList.filter { $0.startDate != $0.endDate }
                let singleList = filteredTodoList.filter { $0.startDate == $0.endDate }
                
                if item % 7 != 0 { // 만약 월요일이 아닐 경우, 오늘 시작하는것들만, 월요일이면 포함되는 전체 다!
                    periodList = periodList.filter { $0.startDate == day.date }
                        .sorted { $0.endDate < $1.endDate }
                } else { //월요일 중에 오늘이 startDate가 아닌 놈들만 startDate로 정렬, 그 뒤에는 전부다 endDate로 정렬하고, 이걸 다시 endDate를 업댓해줘야함!
                    
                    var continuousPeriodList = periodList
                        .filter { $0.startDate != day.date }
                        .sorted{ ($0.startDate == $1.startDate) ? $0.endDate < $1.endDate : $0.startDate < $1.startDate }
                        .map { todo in
                            var tmpTodo = todo
                            tmpTodo.startDate = day.date
                            return tmpTodo
                        }
                    
                    var initialPeriodList = periodList
                        .filter { $0.startDate == day.date } //이걸 바로 end로 정렬해도 되나? -> 애를 바로 end로 정렬할 경우?
                        .sorted{ $0.endDate < $1.endDate }
                    
                    periodList = continuousPeriodList + initialPeriodList
                }
                
                periodList = periodList.map { todo in
                    // 날짜는 day의 date를 사용하고, todo.endDate랑 비교를 해서 이게 같은주에 포함되는지 아닌지를 판단해야함..!
                    let currentWeek = calendar.component(.weekOfYear, from: day.date)
                    let endWeek = calendar.component(.weekOfYear, from: todo.endDate)
                    
                    if currentWeek != endWeek {
                        let firstDayOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: day.date))
                        let lastDayOfWeek = calendar.date(byAdding: .day, value: 6, to: firstDayOfWeek!) //이게 이번주 일요일임.
                        var tmpTodo = todo
                        tmpTodo.endDate = lastDayOfWeek!
                        return tmpTodo
                    } else { return todo }
                }
                
                let periodTodo: [(Int, SocialTodoSummary)] = periodList.compactMap { todo in
                    for i in (0..<viewModel.blockMemo[item].count) {
                        if viewModel.blockMemo[item][i] == nil,
                           let period = Calendar.current.dateComponents([.day], from: todo.startDate, to: todo.endDate).day {
                            for j in (0...period) {
                                viewModel.blockMemo[item+j][i] = todo.todoId
                            }
                            return (i, todo)
                        }
                    }
                    return nil
                }
                
                var singleStartIndex = 0
                viewModel.blockMemo[item].enumerated().forEach { (index, tuple) in
                    if tuple != nil {
                        singleStartIndex = index + 1
                    }
                }
                
                let singleTodo = singleList.enumerated().map { (index, todo) in
                    return (index + singleStartIndex, todo)
                }
                
                var holidayMock: (Int, String)?
                if let holidayTitle = HolidayPool.shared.holidays[day.date] {
                    let holidayIndex = singleStartIndex + singleTodo.count
                    holidayMock = (holidayIndex, holidayTitle)
                }
                
                viewModel.filteredTodoCache[item] = FilteredSocialTodoViewModel(periodTodo: periodTodo, singleTodo: singleTodo, holiday: holidayMock)
            }
        }
        
        let weekRange = (indexPath.item - indexPath.item%7..<indexPath.item - indexPath.item%7 + 7)
        guard let maxItem = viewModel.filteredTodoCache[weekRange]
            .max(by: { a, b in
                let aHeight = (a.holiday != nil) ? a.holiday!.0 : (a.singleTodo.last != nil) ?
                a.singleTodo.last!.0 : (a.periodTodo.last != nil) ? a.periodTodo.last!.0 : 0
                let bHeight = (b.holiday != nil) ? b.holiday!.0 : (b.singleTodo.last != nil) ?
                b.singleTodo.last!.0 : (b.periodTodo.last != nil) ? b.periodTodo.last!.0 : 0
                return aHeight < bHeight
            }) else { return UICollectionViewCell() }
                
        guard var todosHeight = (maxItem.holiday != nil) ?
                maxItem.holiday?.0 : (maxItem.singleTodo.count != 0) ?
                maxItem.singleTodo.last?.0 : (maxItem.periodTodo.count != 0) ?
                maxItem.periodTodo.last?.0 : 0 else { return UICollectionViewCell() }
        
        var height: CGFloat
        if let cellHeight = viewModel.cachedCellHeightForTodoCount[todosHeight] {
            height = cellHeight
        } else {
            let mockCell = DailyCalendarCell(mockFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * UIScreen.main.bounds.width, height: 110))
            mockCell.socialFill(
                periodTodoList: maxItem.periodTodo,
                singleTodoList: maxItem.singleTodo,
                holiday: maxItem.holiday
            )
            
            mockCell.layoutIfNeeded()
            
            let estimatedSize = mockCell.systemLayoutSizeFitting(CGSize(
                width: Double(1)/Double(7) * UIScreen.main.bounds.width,
                height: UIView.layoutFittingCompressedSize.height
            ))
            let estimatedHeight = estimatedSize.height + mockCell.stackView.topY + 3
            let targetHeight = (estimatedHeight > 110) ? estimatedHeight : 110
            height = targetHeight
        }
                
        let day = viewModel.mainDayList[section][indexPath.item]
        let filteredTodo = viewModel.filteredTodoCache[indexPath.item]
        
        cell.fill(
            day: "\(Calendar.current.component(.day, from: day.date))",
            state: day.state,
            weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: day.date)+5)%7)!,
            isToday: day.date == viewModel.today,
            isHoliday: HolidayPool.shared.holidays[day.date] != nil,
            height: height
        )
        
        cell.socialFill(periodTodoList: filteredTodo.periodTodo, singleTodoList: filteredTodo.singleTodo, holiday: filteredTodo.holiday)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let section {
            isSingleSelected?.onNext(IndexPath(item: indexPath.item, section: section))
        }
        return false
    }
}

extension NestedScrollableMonthlyCalendarCell {
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(Double(1)/Double(7)),
            heightDimension: .estimated(110)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(110)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
}

// 옮기고, 리프레시를 해야하는데...!! 그게 안되고있음 타이밍이 겹쳐서... 그니까 이 타이밍 제어를 위해,,,
// 1. 달력 그리기 -> 시작점으로 옮기기, 리프레시하기..?

//
//  MonthlyCalendarCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit
import RxSwift

class MonthlyCalendarCell: UICollectionViewCell {
    
    static let reuseIdentifier = "monthly-calendar-cell"
    
    var viewModel: HomeCalendarViewModel?
    
    var selectionState: Bool = false
    var firstPressedIndexPath: IndexPath?
    var lastPressedIndexPath: IndexPath?
    var section: Int?
    
    var isMultipleSelecting: PublishSubject<Bool>?
    var isMultipleSelected: PublishSubject<(Int, (Int, Int))>?
    var isSingleSelected: PublishSubject<(Int, Int)>?
    
    var bag: DisposeBag?
    
    lazy var lpgr : UILongPressGestureRecognizer = {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        return lpgr
    }()
    
    lazy var pgr: UIPanGestureRecognizer = {
        let pgr = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
        pgr.delegate = self
        return pgr
    }()
    
    func configureGestureRecognizer() {
        self.collectionView.addGestureRecognizer(lpgr)
        self.collectionView.addGestureRecognizer(pgr)
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureGestureRecognizer()
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
    
    func fill(section: Int, viewModel: HomeCalendarViewModel?) {
        self.section = section
        self.viewModel = viewModel
        collectionView.reloadData()
    }
    
    func fill(
        isMultipleSelecting: PublishSubject<Bool>,
        isMultipleSelected: PublishSubject<(Int, (Int, Int))>,
        isSingleSelected: PublishSubject<(Int, Int)>
    ) {
        self.isMultipleSelecting = isMultipleSelecting
        self.isMultipleSelected = isMultipleSelected
        self.isSingleSelected = isSingleSelected
    }
}

extension MonthlyCalendarCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
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
        let dayViewModel = viewModel.mainDayList[section][indexPath.item]
        
        var filteredTodoList = dayViewModel.todoList
        if let filterGroupId = try? viewModel.filteredGroupId.value() {
            filteredTodoList = filteredTodoList.filter( { $0.groupId == filterGroupId })
        }
        cell.delegate = self
        cell.fill(
            day: "\(Calendar.current.component(.day, from: dayViewModel.date))",
            state: dayViewModel.state,
            weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: dayViewModel.date)+5)%7)!
        )
        
        if indexPath.item%7 == 0 {
            viewModel.blockMemo = [[(Int, Bool)?]](repeating: [(Int, Bool)?](repeating: nil, count: 15), count: 7)
        }
    
        var periodList = filteredTodoList.filter { $0.startDate != $0.endDate }
        var singleList = filteredTodoList.filter { $0.startDate == $0.endDate }
        
        // 확인할 케이스
        // 우선 기간투두의 시작에서 확인할거: 주차를 넘어가는지? 이걸 어떻게 판단할까? 일단 이걸로 1차로 짤라야함
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        if indexPath.item % 7 != 0 { // 만약 월요일이 아닐 경우, 오늘 시작하는것들만, 월요일이면 포함되는 전체 다!
            periodList = periodList.filter { $0.startDate == dayViewModel.date }
                .sorted { $0.endDate < $1.endDate }
        } else { //월요일 중에 오늘이 startDate가 아닌 놈들만 startDate로 정렬, 그 뒤에는 전부다 endDate로 정렬하고, 이걸 다시 endDate를 업댓해줘야함!
            var continuousPeriodList = periodList
                .filter { $0.startDate != dayViewModel.date }
                .sorted{ ($0.startDate == $1.startDate) ? $0.endDate < $1.endDate : $0.startDate < $1.startDate }
                .map { todo in
                    var tmpTodo = todo
                    tmpTodo.startDate = dayViewModel.date
                    return tmpTodo
                }
            
            var initialPeriodList = periodList
                .filter { $0.startDate == dayViewModel.date } //이걸 바로 end로 정렬해도 되나? -> 애를 바로 end로 정렬할 경우?
                .sorted{ $0.endDate < $1.endDate }
            
            periodList = continuousPeriodList + initialPeriodList
        }
        
        // 이제 위에서 짤린놈들로 다시 길이를 정돈해야한다..! 내 끝이 내보다 다음주인가? 를 확인해아한다...!!!
        periodList = periodList.map { todo in
            // 날짜는 dayViewModel의 date를 사용하고, todo.endDate랑 비교를 해서 이게 같은주에 포함되는지 아닌지를 판단해야함..!
            let currentWeek = calendar.component(.weekOfYear, from: dayViewModel.date)
            let endWeek = calendar.component(.weekOfYear, from: todo.endDate)
            
            if currentWeek != endWeek {
                let firstDayOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dayViewModel.date))
                let lastDayOfWeek = calendar.date(byAdding: .day, value: 6, to: firstDayOfWeek!) //이게 이번주 일요일임.
                var tmpTodo = todo
                tmpTodo.endDate = lastDayOfWeek!
                return tmpTodo
            } else { return todo }
        } //endDate를 금욜로 짜른것!, 월욜에는 짜르고 정렬해야하나?


        for todo in periodList {
            print(todo.title, todo.startDate, todo.endDate)
            for i in (0..<viewModel.blockMemo[indexPath.item%7].count) {
                if viewModel.blockMemo[indexPath.item%7][i] == nil,
                   let period = Calendar.current.dateComponents([.day], from: todo.startDate, to: todo.endDate).day {
                    for j in (0...period) {
                        print(indexPath.item%7+j, i)
                        viewModel.blockMemo[indexPath.item%7+j][i] = (todo.id!, todo.isGroupTodo)
                    }
                    break
                }
            }
        }
        
        cell.fill(periodTodoList: periodList, singleTodoList: singleList, item: indexPath.item)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section,
              let maxTodoViewModel = viewModel?.getMaxInWeek(indexPath: IndexPath(item: indexPath.item, section: section)) else { return CGSize() }
        
        let screenWidth = UIScreen.main.bounds.width
                
        var todoCount = maxTodoViewModel.todoList.count
        
        if let height = viewModel?.cachedCellHeightForTodoCount[todoCount] {
            return CGSize(width: (Double(1)/Double(7) * screenWidth) - 2, height: Double(height))
            
        } else {
            let mockCell = DailyCalendarCell(mockFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * screenWidth, height: 116))
//            mockCell.delegate = self
//            mockCell.fill(todoList: maxTodoViewModel.todoList, item: indexPath.item)
            mockCell.layoutIfNeeded()
            
            let estimatedSize = mockCell.systemLayoutSizeFitting(CGSize(
                width: Double(1)/Double(7) * screenWidth,
                height: UIView.layoutFittingCompressedSize.height
            ))

            if estimatedSize.height <= 116 {
                viewModel?.cachedCellHeightForTodoCount[todoCount] = 116
                return CGSize(width: (Double(1)/Double(7) * screenWidth) - 2, height: 116)
            } else {
                viewModel?.cachedCellHeightForTodoCount[todoCount] = estimatedSize.height
            
                return CGSize(width: (Double(1)/Double(7) * screenWidth) - 2, height: estimatedSize.height)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let section {
            isSingleSelected?.onNext((section, indexPath.item))
        }
        return false
    }
    
}

extension MonthlyCalendarCell {
    @objc func longTap(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: collectionView)
            guard let nowIndexPath = collectionView.indexPathForItem(at: location) else { return }
            
            selectionState = true

            self.firstPressedIndexPath = nowIndexPath
            self.lastPressedIndexPath = nowIndexPath
            collectionView.selectItem(at: nowIndexPath, animated: true, scrollPosition: [])
        }
    }
    
    // 이부분을 간소화 해야함
    @objc func drag(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard self.selectionState else {
            self.isMultipleSelecting?.onNext(false)
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
            return
        }
        let location = gestureRecognizer.location(in: collectionView)

        guard let nowIndexPath = collectionView.indexPathForItem(at: location) else { return }
        switch gestureRecognizer.state {
        case .began:
            isMultipleSelecting?.onNext(true)
            collectionView.isScrollEnabled = false
            collectionView.isUserInteractionEnabled = false
            collectionView.allowsMultipleSelection = true
        case .changed:
            guard let firstPressedIndexPath = firstPressedIndexPath,
                  let lastPressedIndexPath = lastPressedIndexPath,
                  nowIndexPath != lastPressedIndexPath else { return }
            
            if firstPressedIndexPath.item < lastPressedIndexPath.item {
                if firstPressedIndexPath.item > nowIndexPath.item {
                    (firstPressedIndexPath.item+1...lastPressedIndexPath.item).forEach {
                        self.collectionView.deselectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true)
                    }
                    (nowIndexPath.item..<firstPressedIndexPath.item).forEach {
                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
                    }
                } else if nowIndexPath.item < lastPressedIndexPath.item {
                    (nowIndexPath.item+1...lastPressedIndexPath.item).forEach {
                        self.collectionView.deselectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true)
                    }
                } else if nowIndexPath.item > lastPressedIndexPath.item {
                    (lastPressedIndexPath.item+1...nowIndexPath.item).forEach {
                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
                    }
                }
            } else if (firstPressedIndexPath.item > lastPressedIndexPath.item) {
                if (firstPressedIndexPath.item < nowIndexPath.item) {

                    (lastPressedIndexPath.item..<firstPressedIndexPath.item).forEach {
                        self.collectionView.deselectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true)
                    }
                    (firstPressedIndexPath.item+1...nowIndexPath.item).forEach {
                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
                    }
                } else if lastPressedIndexPath.item < nowIndexPath.item {

                    (lastPressedIndexPath.item..<nowIndexPath.item).forEach {
                        self.collectionView.deselectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true)
                    }
                } else if nowIndexPath.item < lastPressedIndexPath.item {

                    (nowIndexPath.item..<lastPressedIndexPath.item).forEach {
                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
                    }
                }
            } else {
                if nowIndexPath.item > lastPressedIndexPath.item {

                    (lastPressedIndexPath.item+1...nowIndexPath.item).forEach {
                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
                    }
                } else {

                    (nowIndexPath.item..<lastPressedIndexPath.item).forEach {
                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
                    }
                }
            }
            
            self.lastPressedIndexPath = nowIndexPath
        case .ended:
            selectionState = false
            
            guard let section,
                  let firstPressedItem = self.firstPressedIndexPath?.item,
                  let lastPressedItem = self.lastPressedIndexPath?.item else { return }
            self.isMultipleSelected?.onNext((section, (firstPressedItem, lastPressedItem)))

            firstPressedIndexPath = nil
            lastPressedIndexPath = nil
            
            self.isMultipleSelecting?.onNext(false)
            

            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
            collectionView.allowsMultipleSelection = false
            
            guard let paths = self.collectionView.indexPathsForSelectedItems else { return }
            paths.forEach { indexPath in
                self.collectionView.deselectItem(at: indexPath, animated: true)
            }
        default:
            print(gestureRecognizer.state)
        }
    }
}

// MARK: GestureRecognizerDelegate

extension MonthlyCalendarCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MonthlyCalendarCell: DailyCalendarCellDelegate {
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, item: Int, idToFindIndex id: Int, isGroupTodo: Bool) -> Int? {
        viewModel?.blockMemo[item%7].firstIndex { tuple in
            guard let tuple else {
                return false
            }
            return tuple.0 == id && tuple.1 == isGroupTodo
        }
    }
    
    func startIndexOfDailyTodo(_ dayCalendarCell: DailyCalendarCell, item: Int) -> Int {
        var ret = 0
        viewModel?.blockMemo[item%7].enumerated().forEach { (index, tuple) in
            if tuple != nil {
                ret = index + 1
            }
        }
        return ret
    }
    
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfCategoryId id: Int) -> CategoryColor? {
        return viewModel?.categoryDict[id]?.color
    }
    
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfGroupCategoryId id: Int) -> CategoryColor? {
        return viewModel?.groupCategoryDict[id]?.color
    }
}

//
//  MonthlyCalendarCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit
import RxSwift
import RxCocoa

class MonthlyCalendarCell: UICollectionViewCell {
    
    static let reuseIdentifier = "monthly-calendar-cell"
    
    var viewModel: HomeCalendarViewModel?
    
    // MARK: 드래그 해서 기간 일정 만들기
    var selectionState: Bool = false
    var firstPressedIndexPath: IndexPath?
    var lastPressedIndexPath: IndexPath?
    
    var section: Int?
    
    var isMultipleSelecting: PublishRelay<Bool>?
    var isMultipleSelected: PublishRelay<(Int, (Int, Int))>?
    var isSingleSelected: PublishRelay<(Int, Int)>?
    var refreshRequired: PublishRelay<Void>?
    
    var bag: DisposeBag?
    
    lazy var lpgr : UILongPressGestureRecognizer = {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        lpgr.minimumPressDuration = 0.4
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = false
        return lpgr
    }()
    
    lazy var pgr: UIPanGestureRecognizer = {
        let pgr = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
        pgr.delegate = self
        return pgr
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
        cv.showsVerticalScrollIndicator = false
        cv.refreshControl = refreshControl
        cv.register(DailyCalendarCell.self, forCellWithReuseIdentifier: DailyCalendarCell.identifier)
        return cv
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    @objc func refresh(_ sender: UIRefreshControl) {
        refreshRequired?.accept(())
    }
    
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
        
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func configureView() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureGestureRecognizer() {
        self.collectionView.addGestureRecognizer(lpgr)
        self.collectionView.addGestureRecognizer(pgr)
    }
    
    func fill(section: Int, viewModel: HomeCalendarViewModel?) {
        self.section = section
        self.viewModel = viewModel
        UIView.performWithoutAnimation({
            collectionView.reloadData()
        })
    }
    
    func fill(
        isMultipleSelecting: PublishRelay<Bool>,
        isMultipleSelected: PublishRelay<(Int, (Int, Int))>,
        isSingleSelected: PublishRelay<(Int, Int)>,
        refreshRequired: PublishRelay<Void>,
        didFetchRefreshedData: PublishRelay<Void>
    ) {
        self.isMultipleSelecting = isMultipleSelecting
        self.isMultipleSelected = isMultipleSelected
        self.isSingleSelected = isSingleSelected
        self.refreshRequired = refreshRequired
        
        let bag = DisposeBag()
        didFetchRefreshedData
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { view, _ in
                if view.refreshControl.isRefreshing {
                    view.refreshControl.endRefreshing()
                }
            })
            .disposed(by: bag)
        self.bag = bag
    }
    
    func deselectItems() {
        guard let paths = self.collectionView.indexPathsForSelectedItems else { return }
        paths.forEach { indexPath in
            self.collectionView.deselectItem(at: indexPath, animated: true)
        }
        collectionView.allowsMultipleSelection = false
    }
}

extension MonthlyCalendarCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = self.section else { return Int() }
        return viewModel?.mainDays[section].count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section,
              let viewModel,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCell.identifier, for: indexPath) as? DailyCalendarCell else {
            return UICollectionViewCell()
        }
        
        viewModel.stackTodosInDayViewModelOfWeek(at: IndexPath(item: indexPath.item, section: section))
        
        guard let maxItem = viewModel.maxHeightTodosInDayViewModelOfWeek(at: IndexPath(item: indexPath.item, section: section)) else { return UICollectionViewCell() }
        let height = calculateCellHeight(item: maxItem)
        
        let day = viewModel.mainDays[section][indexPath.item]
        let filteredTodo = viewModel.filteredTodoCache[indexPath.item]
        
        cell.delegate = self
        cell.fill(
            day: "\(Calendar.current.component(.day, from: day.date))",
            state: day.state,
            weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: day.date)+5)%7)!,
            isToday: day.date == viewModel.today,
            isHoliday: HolidayPool.shared.holidays[day.date] != nil,
            height: height
        )
        
        cell.fill(periodTodoList: filteredTodo.periodTodo, singleTodoList: filteredTodo.singleTodo, holiday: filteredTodo.holiday)        
        return cell
    }
    
    func calculateCellHeight(item: TodosInDayViewModel) -> CGFloat {
        let todosHeight = ((item.holiday != nil) ?
                           item.holiday?.0 : (item.singleTodo.count != 0) ?
                           item.singleTodo.last?.0 : (item.periodTodo.count != 0) ?
                           item.periodTodo.last?.0 : 0) ?? 0

        if let cellHeight = viewModel?.cachedCellHeightForTodoCount[todosHeight] {
            return cellHeight
        } else {
            let mockCell = DailyCalendarCell(mockFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * UIScreen.main.bounds.width, height: 110))
            mockCell.delegate = self
            mockCell.fill(
                periodTodoList: item.periodTodo,
                singleTodoList: item.singleTodo,
                holiday: item.holiday
            )
            
            mockCell.layoutIfNeeded()
            
            let estimatedSize = mockCell.systemLayoutSizeFitting(CGSize(
                width: Double(1)/Double(7) * UIScreen.main.bounds.width,
                height: UIView.layoutFittingCompressedSize.height
            ))
            let estimatedHeight = estimatedSize.height + mockCell.stackView.topY + 3
            let targetHeight = (estimatedHeight > 110) ? estimatedHeight : 110
            return targetHeight
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let section {
            isSingleSelected?.accept((section, indexPath.item))
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return collectionView.indexPathsForSelectedItems?.contains(indexPath) == false
        
    }
    
    
}

extension MonthlyCalendarCell {
    @objc func longTap(_ gestureRecognizer: UILongPressGestureRecognizer){
        switch gestureRecognizer.state {
        case .began:
            let location = gestureRecognizer.location(in: collectionView)
            guard let nowIndexPath = collectionView.indexPathForItem(at: location) else { return }
            
            selectionState = true
            
            self.firstPressedIndexPath = nowIndexPath
            self.lastPressedIndexPath = nowIndexPath
            collectionView.selectItem(at: nowIndexPath, animated: true, scrollPosition: [])
            Vibration.selection.vibrate()
        case .ended:
            selectionState = false
            
            guard let section,
                  let firstPressedItem = self.firstPressedIndexPath?.item,
                  let lastPressedItem = self.lastPressedIndexPath?.item else { return }
            self.isMultipleSelected?.accept((section, (firstPressedItem, lastPressedItem)))
            
            firstPressedIndexPath = nil
            lastPressedIndexPath = nil
            
            self.isMultipleSelecting?.accept(false)
            
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
        default:
            break
        }
    }
    
    // 이부분을 간소화 해야함
    @objc func drag(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard self.selectionState else {
            self.isMultipleSelecting?.accept(false)
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
            return
        }
        let location = gestureRecognizer.location(in: collectionView)
        
        guard let nowIndexPath = collectionView.indexPathForItem(at: location) else { return }
        switch gestureRecognizer.state {
        case .began:
            isMultipleSelecting?.accept(true)
            collectionView.isScrollEnabled = false
            collectionView.isUserInteractionEnabled = false
            collectionView.allowsMultipleSelection = true
        case .changed:
            guard let firstPressedIndexPath = firstPressedIndexPath,
                  let lastPressedIndexPath = lastPressedIndexPath,
                  lastPressedIndexPath != nowIndexPath else { return }
            
            
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
            Vibration.selection.vibrate()
        default:
            break
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
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfCategoryId id: Int) -> CategoryColor? {
        return viewModel?.memberCategories[id]?.color
    }
    
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfGroupCategoryId id: Int) -> CategoryColor? {
        return viewModel?.groupCategories[id]?.color
    }
}

extension MonthlyCalendarCell {
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

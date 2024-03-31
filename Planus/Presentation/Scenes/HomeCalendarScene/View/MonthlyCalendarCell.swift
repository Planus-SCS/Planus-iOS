//
//  MonthlyCalendarCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MonthlyCalendarCell: UICollectionViewCell {
    
    static let reuseIdentifier = "monthly-calendar-cell"
    
    var viewModel: HomeCalendarViewModel?
    
    // MARK: - Darg for period Todo
    private var selectionState: Bool = false
    private var firstPressedIndexPath: IndexPath?
    private var lastPressedIndexPath: IndexPath?
    
    private var section: Int?
    
    // MARK: - UI Event
    private var nowMultipleSelecting: PublishRelay<Bool>?
    private var multipleItemSelected: PublishRelay<(IndexPath, IndexPath)>?
    private var itemSelected: PublishRelay<IndexPath>?
    private var refreshRequired: PublishRelay<Void>?
    
    var bag: DisposeBag?
    
    private lazy var lpgr : UILongPressGestureRecognizer = {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        lpgr.minimumPressDuration = 0.3
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = false
        return lpgr
    }()
    
    private lazy var pgr: UIPanGestureRecognizer = {
        let pgr = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
        pgr.delegate = self
        return pgr
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
        cv.showsVerticalScrollIndicator = false
        cv.refreshControl = refreshControl
        cv.register(CalendarDailyCell.self, forCellWithReuseIdentifier: CalendarDailyCell.identifier)
        return cv
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
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
        refreshControl.endRefreshing()
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
}

// MARK: Actions
extension MonthlyCalendarCell {
    func deselectItems() {
        guard let paths = self.collectionView.indexPathsForSelectedItems else { return }
        paths.forEach { indexPath in
            self.collectionView.deselectItem(at: indexPath, animated: true)
        }
        collectionView.allowsMultipleSelection = false
    }
    
    @objc 
    func refresh(_ sender: UIRefreshControl) {
        refreshRequired?.accept(())
    }
}

// MARK: Fill
extension MonthlyCalendarCell {
    func fill(section: Int, viewModel: HomeCalendarViewModel?) {
        self.section = section
        self.viewModel = viewModel
        UIView.performWithoutAnimation({
            collectionView.reloadData()
        })
    }
    
    func fill(
        nowMultipleSelecting: PublishRelay<Bool>,
        multipleItemSelected: PublishRelay<(IndexPath, IndexPath)>,
        itemSelected: PublishRelay<IndexPath>,
        refreshRequired: PublishRelay<Void>,
        didFetchRefreshedData: PublishRelay<Void>
    ) {
        self.nowMultipleSelecting = nowMultipleSelecting
        self.multipleItemSelected = multipleItemSelected
        self.itemSelected = itemSelected
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
}

// MARK: configure
extension MonthlyCalendarCell {
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
}

extension MonthlyCalendarCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDailyCell.identifier, for: indexPath) as? CalendarDailyCell else {
            return UICollectionViewCell()
        }

        let day = viewModel.mainDays[section][indexPath.item]

        cell.fill(
            day: "\(Calendar.current.component(.day, from: day.date))",
            state: day.state,
            weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: day.date)+5)%7)!,
            isToday: day.date == viewModel.today,
            isHoliday: HolidayPool.shared.holidays[day.date] != nil
        )
        
        if let item = viewModel.dailyViewModels[day.date] {
            cell.fill(periodTodoList: item.periodTodo, singleTodoList: item.singleTodo, holiday: item.holiday)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let viewModel,
              let section else { return CGSize() }

        let (maxCount, maxTodo) = viewModel.largestDailyViewModelOfWeek(at: IndexPath(item: indexPath.item, section: section))

        if let cellHeight = viewModel.cachedCellHeightForTodoCount[maxCount] {
            return CGSize(width: Double(1)/Double(7) * UIScreen.main.bounds.width - 0.1, height: cellHeight)
        } else {
            var targetHeight: CGFloat = 100
            if let maxTodo {
                let mockCell = CalendarDailyCell(mockableFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * UIScreen.main.bounds.width - 0.1, height: targetHeight))
                
                mockCell.fill(
                    periodTodoList: maxTodo.periodTodo,
                    singleTodoList: maxTodo.singleTodo,
                    holiday: maxTodo.holiday
                )

                let estimatedSize = mockCell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

                let estimatedHeight = estimatedSize.height
                targetHeight = max(estimatedHeight, targetHeight)
            }

            viewModel.cachedCellHeightForTodoCount[maxCount] = targetHeight

            return CGSize(width: Double(1)/Double(7) * UIScreen.main.bounds.width - 0.1, height: targetHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let section {
            itemSelected?.accept(IndexPath(item: indexPath.item, section: section))
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
            
            nowMultipleSelecting?.accept(true)
            
            collectionView.selectItem(at: nowIndexPath, animated: true, scrollPosition: [])
            collectionView.isScrollEnabled = false
            collectionView.isUserInteractionEnabled = false
            collectionView.allowsMultipleSelection = true
            
            Vibration.selection.vibrate()
        case .ended:
            selectionState = false
            
            guard let section,
                  let firstPressedItem = self.firstPressedIndexPath?.item,
                  let lastPressedItem = self.lastPressedIndexPath?.item else { return }
            self.multipleItemSelected?.accept(
                (IndexPath(item: firstPressedItem, section: section),
                 IndexPath(item: lastPressedItem, section: section)
                ))
            
            firstPressedIndexPath = nil
            lastPressedIndexPath = nil
            
            self.nowMultipleSelecting?.accept(false)
            
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
        default:
            break
        }
    }
    
    @objc func drag(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard self.selectionState else {
            self.nowMultipleSelecting?.accept(false)
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
            return
        }
        let location = gestureRecognizer.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
        switch gestureRecognizer.state {
        case .changed:
            guard let firstPressedIndexPath = firstPressedIndexPath,
                  let lastPressedIndexPath = lastPressedIndexPath,
                  lastPressedIndexPath != indexPath else { return }
            
            let indexPathsToDeselect = Set(selectedIndexPaths(from: firstPressedIndexPath, to: lastPressedIndexPath))
            let indexPathsToSelect = Set(selectedIndexPaths(from: firstPressedIndexPath, to: indexPath))
            
            let foo = Array(indexPathsToDeselect.subtracting(indexPathsToSelect))
            let boo = Array(indexPathsToSelect.subtracting(indexPathsToDeselect))

            foo.forEach { collectionView.deselectItem(at: $0, animated: true) }
            boo.forEach { collectionView.selectItem(at: $0, animated: true, scrollPosition: []) }

            self.lastPressedIndexPath = indexPath
            Vibration.selection.vibrate()
        default:
            break
        }
    }
    
    private func selectedIndexPaths(from startIndexPath: IndexPath, to endIndexPath: IndexPath) -> [IndexPath] {
        let section = startIndexPath.section
        let start = min(startIndexPath.item, endIndexPath.item)
        let end = max(startIndexPath.item, endIndexPath.item)
        return (start...end).map { IndexPath(item: $0, section: section) }
    }
}

// MARK: - GestureRecognizerDelegate
extension MonthlyCalendarCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

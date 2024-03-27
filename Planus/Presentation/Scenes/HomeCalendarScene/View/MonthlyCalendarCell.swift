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
    
    // MARK: 드래그 해서 기간 일정 만드는 용
    private var selectionState: Bool = false
    private var firstPressedIndexPath: IndexPath?
    private var lastPressedIndexPath: IndexPath?
    
    private var section: Int?
    
    private var isMultipleSelecting: PublishRelay<Bool>?
    private var isMultipleSelected: PublishRelay<(Int, (Int, Int))>?
    private var isSingleSelected: PublishRelay<(Int, Int)>?
    private var refreshRequired: PublishRelay<Void>?
    
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
}

// MARK: configure UI
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

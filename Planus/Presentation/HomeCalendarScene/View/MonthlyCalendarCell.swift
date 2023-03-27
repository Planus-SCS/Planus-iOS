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
    
    var selectionState: Bool = false
    var firstPressedIndexPath: IndexPath?
    var lastPressedIndexPath: IndexPath?
    var section: Int?
    
    var isMultipleSelecting: PublishSubject<Bool>?
    var isMultipleSelected: PublishSubject<(Int, (Int, Int))>?
    var isSingleSelected: PublishSubject<(Int, Int)>?
    
    weak var delegate: MonthlyCalendarCellDelegate?
    
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
    
    func fill(section: Int, delegate: MonthlyCalendarCellDelegate) {
        self.section = section
        self.delegate = delegate
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
        return delegate?.numberOfItems(self, in: self.section ?? Int()) ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCell.identifier, for: indexPath) as? DailyCalendarCell,
              let dayViewModel = delegate?.monthlyCalendarCell(self, at: IndexPath(item: indexPath.item, section: self.section ?? Int()))  else {
            return UICollectionViewCell()
        }
        
        cell.fill(day: "\(Calendar.current.component(.day, from: dayViewModel.date))", state: dayViewModel.state, weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: dayViewModel.date)+5)%7)!, todoList: dayViewModel.todoList)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let delegate,
              let section,
              let maxTodoViewModel = delegate.monthlyCalendarCell(self, maxCountOfTodoInWeek: IndexPath(item: indexPath.item, section: section)) else { return CGSize() }
        
        let frameSize = delegate.frameWidth(self)
        
        var todoCount = maxTodoViewModel.todoList?.count ?? 0
        
        if let height = delegate.findCachedHeight(self, todoCount: todoCount) {
            return CGSize(width: Double(1)/Double(7) * Double(frameSize.width), height: Double(height))
            
        } else {
            let mockCell = DailyCalendarCell(mockFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * frameSize.width, height: 116))
            mockCell.fill(todoList: maxTodoViewModel.todoList)

            mockCell.layoutIfNeeded()
            
            let estimatedSize = mockCell.systemLayoutSizeFitting(CGSize(width: Double(1)/Double(7) * frameSize.width, height: 116))
            delegate.cacheHeight(self, count: todoCount, height: estimatedSize.height)
            
            return CGSize(width: Double(1)/Double(7) * frameSize.width, height: estimatedSize.height)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let section {
            isSingleSelected?.onNext((section, indexPath.item))
        }
        return false
    }
    
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        if let cell = collectionView.cellForItem(at: indexPath) as? DailyCalendarCell {
//            print("hilight!")
//            let pressedDownTransform = CGAffineTransform(scaleX: 0.98, y: 0.98)
//            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [.curveEaseInOut], animations: { cell.transform = pressedDownTransform })
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        if let cell = collectionView.cellForItem(at: indexPath) as? DailyCalendarCell {
//            print("unhilight")
//            let originalTransform = CGAffineTransform(scaleX: 1, y: 1)
//            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [.curveEaseInOut], animations: { cell.transform = originalTransform })
//        }
//    }
    
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

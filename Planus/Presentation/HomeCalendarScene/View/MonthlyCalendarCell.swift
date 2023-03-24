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
    var firstPressedIndexPath: IndexPath? //드래그한놈들을 전부 유지하고 다시그리게 해야하나?
    var lastPressedIndexPath: IndexPath?
    
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

    var dataSource: MonthlyCalendarViewDataSource = MonthlyCalendarViewDataSource()
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
        // 데이터소스 비우기 정도?
    }
    
    func configureView() {
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        collectionView.showsVerticalScrollIndicator = false
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: CustomCell.identifier)
    }
    
    func fill(dayViewModelList: [DayViewModel]) {
        self.dataSource.dayViewModelList = dayViewModelList
        collectionView.reloadData()
        
    }
    
    var isMultipleSelecting: PublishSubject<Bool>?
    var bag: DisposeBag?
    func fill(isMultipleSelecting: PublishSubject<Bool>) {
        self.isMultipleSelecting = isMultipleSelecting
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
            
            firstPressedIndexPath = nil
            lastPressedIndexPath = nil
            
            self.isMultipleSelecting?.onNext(false)

            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
            collectionView.allowsMultipleSelection = false
            
//            let vc = ViewController2(nibName: nil, bundle: nil)
//            vc.closure1 = { (category: TodoCategory) in
//                guard let paths = self.collectionView.indexPathsForSelectedItems else { return }
//
//                paths.forEach { indexPath in
//                    let viewModel = self.dataSource.dayViewModelList[indexPath.item]
//                    let todo = Todo(title: "test", date: viewModel.date, category: category, type: .normal)
////                    self.viewModel?.todoContainer.append(item: todo, date: viewModel.date)
////                    self.viewModel?.days[indexPath.section][indexPath.item].todo.append(todo)
//                }
//
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//            }
//
//            vc.closure2 = { () in
//                guard let paths = self.collectionView.indexPathsForSelectedItems else { return }
//                paths.forEach { indexPath in
//                    self.collectionView.deselectItem(at: indexPath, animated: true)
//                }
//            }
//
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .pageSheet
//            if let sheet = nav.sheetPresentationController {
//                sheet.detents = [.medium()]
//            }
////            self.navigationController?.topViewController?.present(nav, animated: true)
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

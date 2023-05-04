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
    
    var isSingleSelected: PublishSubject<IndexPath>?
    
    weak var delegate: NestedScrollableMonthlyCalendarCellDelegate?
    
    var bag: DisposeBag?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
    
    func fill(section: Int, delegate: NestedScrollableMonthlyCalendarCellDelegate, nestedScrollableCellDelegate: NestedScrollableCellDelegate) {
        self.section = section
        self.delegate = delegate
        self.nestedScrollableCellDelegate = nestedScrollableCellDelegate
        collectionView.reloadData()
    }
    
    func fill(
        isSingleSelected: PublishSubject<IndexPath>
    ) {
        self.isSingleSelected = isSingleSelected
    }
}

extension NestedScrollableMonthlyCalendarCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
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
        
        cell.fill(delegate: self, day: "\(Calendar.current.component(.day, from: dayViewModel.date))", state: dayViewModel.state, weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: dayViewModel.date)+5)%7)!, todoList: dayViewModel.todoList)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let delegate,
              let section,
              let maxTodoViewModel = delegate.monthlyCalendarCell(self, maxCountOfTodoInWeek: IndexPath(item: indexPath.item, section: section)) else { return CGSize() }
        
        let frameSize = delegate.frameWidth(self)
        
        var todoCount = maxTodoViewModel.todoList.count
        
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
            isSingleSelected?.onNext(IndexPath(item: indexPath.item, section: section))
        }
        return false
    }
}


// 내부의 콜렉션뷰를 위해 델리게이트로 뷰컨쪽에서 정보 받아오기
protocol NestedScrollableMonthlyCalendarCellDelegate: NSObject {
    func monthlyCalendarCell(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell, at indexPath: IndexPath) -> DayViewModel?
    func monthlyCalendarCell(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell, maxCountOfTodoInWeek indexPath: IndexPath) -> DayViewModel?
    func numberOfItems(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell, in section: Int) -> Int?
    func findCachedHeight(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell, todoCount: Int) -> Double?
    func cacheHeight(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell, count: Int, height: Double)
    func frameWidth(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell) -> CGSize
}

extension NestedScrollableMonthlyCalendarCell: DailyCalendarCellDelegate {
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfCategoryId: Int) -> CategoryColor? {
        return CategoryColor.blue
    }
}

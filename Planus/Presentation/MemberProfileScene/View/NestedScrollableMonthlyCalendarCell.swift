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

extension NestedScrollableMonthlyCalendarCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = self.section else { return Int() }
        return viewModel?.mainDayList[section].count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCell.identifier, for: indexPath) as? DailyCalendarCell,
              let dayViewModel = viewModel?.mainDayList[section][indexPath.item] else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        cell.fill(
            day: "\(Calendar.current.component(.day, from: dayViewModel.date))",
            state: dayViewModel.state,
            weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: dayViewModel.date)+5)%7)!
        )
        
        cell.fill(todoList: dayViewModel.todoList)

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
            mockCell.fill(todoList: maxTodoViewModel.todoList)
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
            isSingleSelected?.onNext(IndexPath(item: indexPath.item, section: section))
        }
        return false
    }
}

extension NestedScrollableMonthlyCalendarCell: DailyCalendarCellDelegate {
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfCategoryId id: Int) -> CategoryColor? {
        return viewModel?.categoryDict[id]?.color
    }
}

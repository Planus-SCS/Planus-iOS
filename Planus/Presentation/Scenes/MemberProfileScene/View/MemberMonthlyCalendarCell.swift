//
//  MemberMonthlyCalendarCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift

class MemberMonthlyCalendarCell: NestedScrollableCell {
    
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
        collectionView.register(CalendarDailyCell.self, forCellWithReuseIdentifier: CalendarDailyCell.identifier)
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

extension MemberMonthlyCalendarCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = self.section else { return Int() }
        return viewModel?.mainDays[section].count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel,
              let section,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDailyCell.identifier, for: indexPath) as? CalendarDailyCell else { return UICollectionViewCell() }
        viewModel.stackTodosInDayViewModelOfWeek(at: IndexPath(item: indexPath.item, section: section))
        
        guard let maxItem = viewModel.maxHeightTodosInDayViewModelOfWeek(at: IndexPath(item: indexPath.item, section: section)) else { return UICollectionViewCell() }
        let height = calculateCellHeight(item: maxItem)
        
        let day = viewModel.mainDays[section][indexPath.item]
        let filteredTodo = viewModel.todosInDayViewModels[indexPath.item]
        
        cell.fill(
            day: "\(Calendar.current.component(.day, from: day.date))",
            state: day.state,
            weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: day.date)+5)%7)!,
            isToday: day.date == viewModel.today,
            isHoliday: HolidayPool.shared.holidays[day.date] != nil
        )
        
        cell.fill(periodTodoList: filteredTodo.periodTodo, singleTodoList: filteredTodo.singleTodo, holiday: filteredTodo.holiday)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let section {
            isSingleSelected?.onNext(IndexPath(item: indexPath.item, section: section))
        }
        return false
    }
    
    func calculateCellHeight(item: SocialTodosInDayViewModel) -> CGFloat {
        let todosHeight = ((item.holiday != nil) ?
                           item.holiday?.0 : (item.singleTodo.count != 0) ?
                           item.singleTodo.last?.0 : (item.periodTodo.count != 0) ?
                           item.periodTodo.last?.0 : 0) ?? 0

        if let cellHeight = viewModel?.cachedCellHeightForTodoCount[todosHeight] {
            return cellHeight
        } else {
            let mockCell = CalendarDailyCell(frame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * UIScreen.main.bounds.width, height: 110))
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
            let estimatedHeight = estimatedSize.height + 3
            let targetHeight = (estimatedHeight > 110) ? estimatedHeight : 110
            return targetHeight
        }
    }
}



extension MemberMonthlyCalendarCell {
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

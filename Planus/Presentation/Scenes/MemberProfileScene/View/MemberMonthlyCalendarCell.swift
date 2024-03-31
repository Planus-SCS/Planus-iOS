//
//  MemberMonthlyCalendarCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift
import RxCocoa

final class MemberMonthlyCalendarCell: NestedScrollableCell {
    
    static let reuseIdentifier = "nested-scrollable-monthly-calendar-cell"
    
    private var section: Int?
    private var viewModel: MemberProfileViewModel?
    
    private var itemSelected: PublishRelay<IndexPath>?
    
    private var bag: DisposeBag?
    
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
        cv.alwaysBounceVertical = true
        cv.register(CalendarDailyCell.self, forCellWithReuseIdentifier: CalendarDailyCell.identifier)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - configure
extension MemberMonthlyCalendarCell {
    func configureView() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.register(CalendarDailyCell.self, forCellWithReuseIdentifier: CalendarDailyCell.identifier)
    }
}

// MARK: - Fill
extension MemberMonthlyCalendarCell {
    func fill(section: Int, viewModel: MemberProfileViewModel?) {
        self.section = section
        self.viewModel = viewModel
        collectionView.reloadData()
    }
    
    func fill(
        itemSelected: PublishRelay<IndexPath>
    ) {
        self.itemSelected = itemSelected
    }
}

extension MemberMonthlyCalendarCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
            day: "\(sharedCalendar.component(.day, from: day.date))",
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
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let section {
            itemSelected?.accept(IndexPath(item: indexPath.item, section: section))
        }
        return false
    }
}

//
//  JoinedGroupCalendarDataSource.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit

class CalendarDataSource: NSObject, UICollectionViewDataSource {
    static let headerElementKind = "joined-group-detail-view-controller-header-kind"
    
    weak var delegate: CalendarDataSourceDelegate?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.dayCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCell.identifier, for: indexPath) as? DailyCalendarCell,
              let dayViewModel = delegate?.dayViewModel(index: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        cell.fill(day: "\(Calendar.current.component(.day, from: dayViewModel.date))", state: dayViewModel.state, weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: dayViewModel.date)+5)%7)!, todoList: dayViewModel.todoList)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: JoinedGroupDetailCalendarHeaderView.reuseIdentifier, for: indexPath) as? JoinedGroupDetailCalendarHeaderView else { return UICollectionReusableView() }
        return view
    }
}

//
//  DayPickerViewController+UICollectionViewDataSource.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

extension DayPickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DayPickerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? DayPickerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let item = days[indexPath.section][indexPath.row]
        
        var rangeState: DayPickerModelRangeState
        switch (firstSelectedDate, lastSelectedDate) {
        case (nil, nil):
            rangeState = .none
        case (let first, nil):
            rangeState = (first == item.date) ? .only : .none
        case (let first, let last):
            if let first,
               let last {
                switch item.date {
                case (first+1..<last):
                    rangeState = .inRange
                case first:
                    rangeState = .start
                case last:
                    rangeState = .end
                default:
                    rangeState = .none
                }
            } else {
                rangeState = .none
            }
        }
        
        cell.fill(day: item.dayLabel, state: item.monthState, rangeState: rangeState)
        return cell
    }

}

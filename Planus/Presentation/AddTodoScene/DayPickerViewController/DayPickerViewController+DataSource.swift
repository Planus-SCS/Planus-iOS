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
        cell.fill(day: item.dayLabel, state: item.monthState, rangeState: item.rangeState)
        return cell
    }

}

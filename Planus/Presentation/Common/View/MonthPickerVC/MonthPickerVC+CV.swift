//
//  MonthPickerVC+CV.swift
//  Planus
//
//  Created by Sangmin Lee on 3/19/24.
//

import UIKit

extension MonthPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let centeredYear,
              let completion else { return }
        
        let component = DateComponents(year: centeredYear, month: indexPath.item + 1)
        let date = Calendar.current.date(from: component) ?? Date()
        completion(date)
        self.dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthPickerCell.reuseIdentifier, for: indexPath) as? MonthPickerCell else {
            return UICollectionViewCell()
        }
        
        var isValid: Bool
        
        guard let firstYear = firstYear,
              let firstMonth = firstMonth,
              let lastYear = lastYear,
              let lastMonth = lastMonth,
              let centeredYear = centeredYear,
              let currentYear = currentYear,
              let currentMonth = currentMonth else { return UICollectionViewCell() }
        var sectionYear = centeredYear + indexPath.section - 1
        
        if firstYear < sectionYear,
           sectionYear < lastYear {
            isValid = true
        } else if firstYear == sectionYear,
                  firstMonth > indexPath.item + 1 {
            isValid = false
        } else if lastYear == sectionYear,
                  lastMonth < indexPath.item + 1 {
            isValid = false
        } else if firstYear > sectionYear {
            isValid = false
        } else if lastYear < sectionYear {
            isValid = false
        } else {
            isValid = true
        }
        cell.fill(
            month: monthData[indexPath.item],
            isCurrent: (sectionYear == currentYear) && (indexPath.item+1 == currentMonth),
            isValid: isValid
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthData.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Double(scrollView.contentOffset.x)/Double(290)
        if index < 1 && ceil(index) == 0 {
            scrollView.setContentOffset(CGPoint(x: 290, y: 0), animated: false) //이때 앞으로 전진한거임. year를 하나 앞으로 바꾸고 리로드해야함
            centeredYear?-=1
            yearLabel.text = "\(centeredYear ?? 0)년"
            collectionView.reloadData()
        } else if index > 1 && floor(index) == 2 {
            scrollView.setContentOffset(CGPoint(x: 290, y: 0), animated: false)
            centeredYear?+=1
            yearLabel.text = "\(centeredYear ?? 0)년"
            collectionView.reloadData()
        }
        
        if index.truncatingRemainder(dividingBy: 1.0) == 0 {
            DispatchQueue.main.async { [weak self] in
                self?.prevButton.isUserInteractionEnabled = true
                self?.nextButton.isUserInteractionEnabled = true
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.prevButton.isUserInteractionEnabled = false
                self?.nextButton.isUserInteractionEnabled = false
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            DispatchQueue.main.async {
                scrollView.isUserInteractionEnabled = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            scrollView.isUserInteractionEnabled = true
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .absolute(34)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(50)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
}

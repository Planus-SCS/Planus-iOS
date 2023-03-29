//
//  DayPickerViewController+Delegate.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

extension DayPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.dayPickerViewController(self, didSelectDate: days[indexPath.section][indexPath.item].date)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            DispatchQueue.main.async { [weak self] in
                scrollView.isUserInteractionEnabled = false
                self?.dayPickerView?.prevButton.isUserInteractionEnabled = false
                self?.dayPickerView?.nextButton.isUserInteractionEnabled = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.async { [weak self] in
            scrollView.isUserInteractionEnabled = true
            self?.dayPickerView?.prevButton.isUserInteractionEnabled = true
            self?.dayPickerView?.nextButton.isUserInteractionEnabled = true
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pointX = scrollView.contentOffset.x
        let frameWidth = self.view.frame.width
        guard frameWidth != 0 else { return }
        
        let newIndex = pointX/frameWidth
        let prevIndex = Double(currentIndex)
        guard newIndex != prevIndex else { return }
        
        let intIndex = Int(newIndex < prevIndex ? ceil(newIndex) : floor(newIndex))
        scrolledTo(index: intIndex)
    }
}

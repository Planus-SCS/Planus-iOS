//
//  DayPickerViewController+Delegate.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

extension DayPickerViewController: UICollectionViewDelegate {
    
    // 스크롤 갈기면 초기화 시켜버리자, 그럼 무조건 first랑 second랑 섹션이 같음
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let first = firstSelectedIndexPath,
           let second = secondSelectedIndexPath {
            // 먼저 원래꺼를 해제해야함
            if first.item < second.item {
                for i in (first.item...second.item) {
                    days[first.section][i].rangeState = .none
                }
            } else {
                for i in (second.item...first.item) {
                    days[first.section][i].rangeState = .none
                }
            }
            days[indexPath.section][indexPath.item].rangeState = .only

            self.firstSelectedIndexPath = indexPath
            self.secondSelectedIndexPath = nil
            delegate?.dayPickerViewController(self, didSelectDate: days[indexPath.section][indexPath.item].date)
            UIView.performWithoutAnimation {
                collectionView.reloadData()
            }
        } else if let first = firstSelectedIndexPath {
            secondSelectedIndexPath = indexPath
            if first.section != indexPath.section {
                days[first.section][first.item].rangeState = .none
                days[indexPath.section][indexPath.item].rangeState = .only
                firstSelectedIndexPath = indexPath
                UIView.performWithoutAnimation {
                    collectionView.reloadData()
                }
                delegate?.dayPickerViewController(self, didSelectDate: days[indexPath.section][indexPath.item].date)
            }
            else if first.item == indexPath.item {
                days[indexPath.section][indexPath.item].rangeState = .none
                collectionView.reloadItems(at: [indexPath])
                delegate?.unHighlightAllItem(self)
                // 그다음할거는????? none으로 바꿨으니까,,,
            }
            else {
                if (first.item < indexPath.item) {
                    for i in (first.item+1..<indexPath.item) {
                        days[first.section][i].rangeState = .inRange
                    }
                    days[first.section][first.item].rangeState = .start
                    days[indexPath.section][indexPath.item].rangeState = .end
                } else {
                    for i in (indexPath.item+1..<first.item) {
                        days[first.section][i].rangeState = .inRange
                    }
                    days[indexPath.section][indexPath.item].rangeState = .start
                    days[first.section][first.item].rangeState = .end
                }
                UIView.performWithoutAnimation {
                    collectionView.reloadData()
                }
                delegate?.dayPickerViewController(self, didSelectDateInRange: (
                        days[indexPath.section][indexPath.row].date,
                        days[first.section][first.row].date
                ))
            }
        } else {
            firstSelectedIndexPath = indexPath
            days[indexPath.section][indexPath.item].rangeState = .only
            delegate?.dayPickerViewController(self, didSelectDate: days[indexPath.section][indexPath.item].date)
            UIView.performWithoutAnimation {
                collectionView.reloadItems(at: [indexPath])
            }
        }
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
        // 만약 2회째 누른놈이 섹션이 다르면? 첫놈 없애자
    }
}

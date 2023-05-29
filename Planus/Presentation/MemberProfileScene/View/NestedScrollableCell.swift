//
//  NestedScrollableCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit

class NestedScrollableCell: UICollectionViewCell {
    var topViewInitialHeight: CGFloat?
    var topViewFinalHeight: CGFloat?
    var topViewHeightConstraintRange: Range<CGFloat> {
        (topViewFinalHeight ?? 0)..<(topViewInitialHeight ?? 0)
    }
    
    weak var nestedScrollableCellDelegate: NestedScrollableCellDelegate?
    
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
    
    func fill(headerInitialHeight: CGFloat?, headerFinalHeight: CGFloat?) {
        self.topViewInitialHeight = headerInitialHeight
        self.topViewFinalHeight = headerFinalHeight
    }
}

extension NestedScrollableCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        let topViewCurrentHeightConst = nestedScrollableCellDelegate?.currentHeaderHeight
        
        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
 
            if delta > 0,
                topViewUnwrappedHeight > topViewHeightConstraintRange.lowerBound,
                scrollView.contentOffset.y > 0 {
                dragDirection = .Up
                nestedScrollableCellDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
            
            if delta < 0,
                scrollView.contentOffset.y < 0 {
                dragDirection = .Down
                nestedScrollableCellDelegate?.innerTableViewDidScroll(withDistance: delta)
            }
        }
        oldContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y <= 0 {
            nestedScrollableCellDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        if scrollView.contentOffset.y <= 0 {
            nestedScrollableCellDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
}

protocol NestedScrollableCellDelegate: AnyObject {
    
    var currentHeaderHeight: CGFloat? { get }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection)
}

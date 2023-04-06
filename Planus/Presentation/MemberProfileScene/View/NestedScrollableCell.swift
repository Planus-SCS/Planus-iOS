//
//  NestedScrollableCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit

var memberProfileTopViewInitialHeight : CGFloat = 208

let memberProfileTopViewFinalHeight : CGFloat = 98 //navigation hieght

let memberProfileTopViewHeightConstraintRange = memberProfileTopViewFinalHeight..<memberProfileTopViewInitialHeight

class NestedScrollableCell: UICollectionViewCell {
    weak var nestedScrollableCellDelegate: NestedScrollableCellDelegate?
    
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
}

extension NestedScrollableCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        let topViewCurrentHeightConst = nestedScrollableCellDelegate?.currentHeaderHeight
        
        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
 
            if delta > 0,
                topViewUnwrappedHeight > memberProfileTopViewHeightConstraintRange.lowerBound,
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

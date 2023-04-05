//
//  InnerScrollableViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit
import SnapKit

var topViewInitialHeight : CGFloat = 220

let topViewFinalHeight : CGFloat = 40 //navigation hieght

let topViewHeightConstraintRange = topViewFinalHeight..<topViewInitialHeight

enum DragDirection {
    case Up
    case Down
}

class NestedScrollableViewController: UIViewController {
    weak var delegate: NestedScrollableViewScrollDelegate?
    
    //MARK:- Stored Properties for Scroll Delegate
    
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
}

extension NestedScrollableViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        let topViewCurrentHeightConst = delegate?.currentHeaderHeight
        
        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
            
            /**
             *  Re-size (Shrink) the top view only when the conditions meet:-
             *  1. The current offset of the table view should be greater than the previous offset indicating an upward scroll.
             *  2. The top view's height should be within its minimum height.
             *  3. Optional - Collapse the header view only when the table view's edge is below the above view - This case will occur if you are using Step 2 of the next condition and have a refresh control in the table view.
             */
            if delta > 0,
                topViewUnwrappedHeight > topViewHeightConstraintRange.lowerBound,
                scrollView.contentOffset.y >= 0 {
                scrollView.decelerationRate = .normal
                dragDirection = .Up
                delegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
            
            /**
             *  Re-size (Expand) the top view only when the conditions meet:-
             *  1. The current offset of the table view should be lesser than the previous offset indicating an downward scroll.
             *  2. Optional - The top view's height should be within its maximum height. Skipping this step will give a bouncy effect. Note that you need to write extra code in the outer view controller to bring back the view to the maximum possible height.
             *  3. Expand the header view only when the table view's edge is below the header view, else the table view should first scroll till it's offset is 0 and only then the header should expand.
             */
            if delta < 0,
                // topViewUnwrappedHeight < topViewHeightConstraintRange.upperBound,
                scrollView.contentOffset.y < 0 {
                dragDirection = .Down
                delegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
        }
        
        oldContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        //You should not bring the view down until the table view has scrolled down to it's top most cell.

        if scrollView.contentOffset.y <= 0 {
            delegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //You should not bring the view down until the table view has scrolled down to it's top most cell.
        
        if scrollView.contentOffset.y <= 0 {
            delegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
}


protocol NestedScrollableViewScrollDelegate: class {
    
    var currentHeaderHeight: CGFloat? { get }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection)
}

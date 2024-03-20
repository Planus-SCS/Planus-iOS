//
//  InnerScrollableViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit
import SnapKit

var joinedGroupTopViewInitialHeight : CGFloat = 220 + UIApplication.shared.statusBarFrame.size.height + 44

let joinedGroupTopViewFinalHeight : CGFloat = 40 + UIApplication.shared.statusBarFrame.size.height + 44 //navigation hieght

let joinedGroupTopViewHeightConstraintRange = joinedGroupTopViewFinalHeight..<joinedGroupTopViewInitialHeight

enum DragDirection {
    case Up
    case Down
}

class NestedScrollableViewController: UIViewController {
    weak var scrollDelegate: NestedScrollableViewScrollDelegate?
    
    //MARK:- Stored Properties for Scroll Delegate
    
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
}

extension NestedScrollableViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        let topViewCurrentHeightConst = scrollDelegate?.currentHeaderHeight
        
        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
 
            if delta > 0,
                topViewUnwrappedHeight > joinedGroupTopViewHeightConstraintRange.lowerBound,
                scrollView.contentOffset.y > 0 {
                dragDirection = .Up
                scrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
            
            if delta < 0,
                scrollView.contentOffset.y < 0 {
                dragDirection = .Down
                scrollDelegate?.innerTableViewDidScroll(withDistance: delta)
            }
        }
        
        oldContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y <= 0 {
            scrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        if scrollView.contentOffset.y <= 0 {
            scrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
}


protocol NestedScrollableViewScrollDelegate: class {
    
    var currentHeaderHeight: CGFloat? { get }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection)
}

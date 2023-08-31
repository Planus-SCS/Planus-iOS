//
//  UIView+Skeleton.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/31.
//

import UIKit

extension UIView {
    private struct AssociatedKeys {
        static var skeletonLayer = "SkeletonViewAssociatedKey"
        static var isSkeletonable = "SkeletonableAssociatedKey"
    }
    
    private var skeletonLayer: SkeletonLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.skeletonLayer) as? SkeletonLayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.skeletonLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var isSkeletonable: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isSkeletonable) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isSkeletonable, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func startSkeletonAnimation() {
        recursiveSearchSubviews(toDo: { (view) in
            if view.isSkeletonable {
                let skeletonLayer = SkeletonLayer(holder: view)
                view.skeletonLayer = skeletonLayer
                skeletonLayer.startAnimating()
            }
        })
    }
    
    public func stopSkeletonAnimation() {
        recursiveSearchSubviews(toDo: { (view) in
            if view.isSkeletonable {
                view.skeletonLayer?.stopAnimating()
                view.skeletonLayer = nil
            }
        })
    }
    
    private func recursiveSearchSubviews(toDo: (UIView) -> Void) {
        subviews.forEach { subview in
            subview.recursiveSearchSubviews(toDo: toDo)
        }
        toDo(self)
    }
}

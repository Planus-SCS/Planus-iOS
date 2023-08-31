//
//  UIView+Skeleton.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/31.
//

import UIKit

struct SkeletonAttribute {
    var shadowOpacity: Float
    var backgroundColor: UIColor?
    var userInteractionEnabled: Bool
}

extension UIView {
    private struct AssociatedKeys {
        static var skeletonLayer = "SkeletonLayerAssociatedKey"
        static var isSkeletonable = "isSkeletonableAssociatedKey"
        static var skeletonAttribute = "SkeletonAttributeAssociatedKey"
    }
    
    private var skeletonLayer: SkeletonLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.skeletonLayer) as? SkeletonLayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.skeletonLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var skeletonAttribute: SkeletonAttribute? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.skeletonAttribute) as? SkeletonAttribute
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.skeletonAttribute, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
            skeletonAttribute = SkeletonAttribute(
                shadowOpacity: self.layer.shadowOpacity,
                backgroundColor: self.backgroundColor,
                userInteractionEnabled: self.isUserInteractionEnabled
            )
            
            view.backgroundColor = .clear
            view.layer.shadowOpacity = 0
            view.isUserInteractionEnabled = false
            if view.isSkeletonable {
                let skeletonLayer = SkeletonLayer(holder: view)
                view.skeletonLayer = skeletonLayer
                skeletonLayer.startAnimating()
            }
        })
    }
    
    public func stopSkeletonAnimation() {
        recursiveSearchSubviews(toDo: { (view) in
            guard let attribute = view.skeletonAttribute else { return }
            
            view.backgroundColor = attribute.backgroundColor
            view.layer.shadowOpacity = attribute.shadowOpacity
            view.isUserInteractionEnabled = attribute.userInteractionEnabled
            
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

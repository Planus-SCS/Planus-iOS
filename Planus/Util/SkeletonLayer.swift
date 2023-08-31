//
//  SkeletonLayer.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/31.
//

import UIKit

class SkeletonLayer: CAGradientLayer {
    
    let animation: CAAnimation = {
        let startPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.startPoint))
        startPointAnim.fromValue = CGPoint(x: -1, y: 0.5)
        startPointAnim.toValue = CGPoint(x: 1, y: 0.5)

        let endPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.endPoint))
        endPointAnim.fromValue = CGPoint(x: 0, y: 0.5)
        endPointAnim.toValue = CGPoint(x: 2, y: 0.5)
        
        let delay = CABasicAnimation()

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [startPointAnim, endPointAnim, delay]
        animationGroup.duration = 1.2
        animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animationGroup.repeatCount = .infinity
        animationGroup.autoreverses = false
        animationGroup.isRemovedOnCompletion = false
        return animationGroup
    }()
    
    weak var holder: UIView?
    
    convenience init(holder: UIView) {
        self.init()
        self.holder = holder
        
        configureLayer()
    }
    
    func configureLayer() {
        self.colors = [UIColor.white.cgColor, UIColor.lightGray.cgColor, UIColor.white.cgColor]
        self.locations = [0, 0.5, 1]
        self.frame = UIScreen.main.bounds
    }
    
    func startAnimating() {
        holder?.layer.mask = self
        holder?.layer.addSublayer(self)
        holder?.clipsToBounds = true
        setOpacity(from: 0, to: 1, duration: 1) {
            DispatchQueue.main.async { CATransaction.begin() }
            self.add(self.animation, forKey: "skeletonAnimation")
            DispatchQueue.main.async { CATransaction.commit() }
        }
    }
    
    func stopAnimating() {
        setOpacity(from: 1, to: 0, duration: 3, completion: { [weak self] in
            guard let self else { return }
            self.holder?.layer.mask = nil
            self.removeFromSuperlayer()
        })
    }
    
    func setOpacity(from: Int, to: Int, duration: TimeInterval, completion: (() -> Void)?) {
        DispatchQueue.main.async { CATransaction.begin() }
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        DispatchQueue.main.async { CATransaction.setCompletionBlock(completion) }
        add(animation, forKey: "setOpacityAnimation")
        DispatchQueue.main.async { CATransaction.commit() }
    }
}

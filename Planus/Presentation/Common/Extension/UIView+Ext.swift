//
//  UIView+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/17.
//

import UIKit

enum GradientAxis {
    case topToBottom
    case leftToRight
}
extension UIView {
    func setTowColorGradient(color1: UIColor, color2: UIColor, axis: GradientAxis) {
        let gradient = CAGradientLayer()
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.locations = [0.0, 1.0]
        switch axis {
        case .topToBottom:
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        case .leftToRight:
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        }
        gradient.frame = bounds
        gradient.masksToBounds = true
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension UIView {
    
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
    
    func setAnimatedIsHidden(_ isHidden: Bool, duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        if isHidden {
            UIView.animate(
                withDuration: duration,
                animations: { self.alpha = 0 },
                completion: { (value: Bool) in
                    self.isHidden = true
                    if let complete = onCompletion { complete() }
                }
            )
        } else {
            self.isHidden = false
            self.alpha = 0
            UIView.animate(
                withDuration: duration,
                animations: { self.alpha = 1 },
                completion: { (value: Bool) in
                    if let complete = onCompletion { complete() }
                }
            )
        }
    }
}


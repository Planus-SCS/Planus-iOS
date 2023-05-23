//
//  SpringableButton.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import UIKit

class SpringableButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                springIn()
            } else {
                springOut()
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.alpha = 1.0
            } else {
                self.alpha = 0.5
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.adjustsImageWhenHighlighted = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func springIn() {
        UIView.animate(withDuration: 0.07, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }
    
    func springOut() {
        UIView.animate(withDuration: 0.07, delay: 0, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
}

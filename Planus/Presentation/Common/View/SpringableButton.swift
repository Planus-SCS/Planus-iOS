//
//  SpringableButton.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import UIKit

class SpringableButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAction() {
        self.addTarget(self, action: #selector(springIn), for: .touchDown)
        self.addTarget(self, action: #selector(springOut), for: .touchUpInside)
        self.addTarget(self, action: #selector(springOut), for: .touchUpOutside)
    }
    
    @objc func springIn() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }
    
    @objc func springOut() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
}

//
//  SpringableCollectionViewCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import UIKit

class SpringableCollectionViewCell: UICollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                springIn()
            } else {
                springOut()
            }
        }
    }
    
    func springIn() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }
    
    func springOut() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
}

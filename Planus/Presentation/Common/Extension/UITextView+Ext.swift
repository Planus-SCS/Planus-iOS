//
//  UITextView+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/11.
//

import UIKit

extension UITextView {
    var numberOfLines: Int {
        let size = CGSize(width: frame.width, height: .infinity)
        let estimatedSize = sizeThatFits(size)
        
        return Int(estimatedSize.height / (self.font!.lineHeight))
    }
}

//
//  PaddedLabel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/23.
//

import UIKit

class PaddingLabel: UILabel {
    
    var contentInset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    
    convenience init(inset: UIEdgeInsets) {
        self.init(frame: .zero)
        self.contentInset = inset
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInset))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + contentInset.left + contentInset.right, height: size.height + contentInset.top + contentInset.bottom)
    }
    
    override var bounds: CGRect {
        didSet { preferredMaxLayoutWidth = bounds.width - (contentInset.left + contentInset.right) }
    }
}

//
//  ValidationCheckView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import UIKit

class ValidationCheckImageView: UIImageView {    
    convenience init() {
        let checkImage = UIImage(named: "uncheck")?.withRenderingMode(.alwaysTemplate)
        
        self.init(frame: CGRect(x: 0, y: 0, width: checkImage?.size.width ?? 0, height: checkImage?.size.height ?? 0))
        self.image = checkImage
    }
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private override init(image: UIImage?) {
        super.init(image: image)
    }
    
    private override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func isValid(_ isValid: Bool) {
        self.tintColor = isValid ? UIColor(hex: 0x99F370) : UIColor(hex: 0x6F81A9)
    }
}

//
//  ValidationCheckView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import UIKit

class ValidationCheckImageView: UIImageView {
    var checkImage: UIImage?
    var uncheckImage: UIImage?
    
    convenience init() {
        let checkImage = UIImage(named: "check")
        let uncheckImage = UIImage(named: "uncheck")
        
        self.init(frame: CGRect(x: 0, y: 0, width: checkImage?.size.width ?? 0, height: checkImage?.size.height ?? 0))
        self.checkImage = checkImage
        self.uncheckImage = uncheckImage
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
        self.image = isValid ? checkImage : uncheckImage
    }
}

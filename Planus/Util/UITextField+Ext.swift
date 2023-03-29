//
//  UITextField+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

extension UITextField {
    func addleftimage(image: UIImage, padding: CGFloat) {
        let leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        leftImage.image = image
        let leftView = UIView(frame: .zero)
        leftView.addSubview(leftImage)
        leftView.snp.makeConstraints {
            $0.width.equalTo(image.size.width + padding * 2)
            $0.height.equalTo(image.size.height)
        }
        leftImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(image.size.width)
            $0.height.equalTo(image.size.height)
        }
        self.leftView = leftView
        self.leftViewMode = .always
    }
}

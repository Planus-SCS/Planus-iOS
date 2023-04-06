//
//  UIImage+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

extension UIImage {
    /// 이미지의 크기를 재조정하는 메서드입니다.
    ///
    /// 메모리 관리를 위해 사용합니다. 재조정 없이 사용할 경우, 앱이 너무 많은 메모리를 사용하게 됩니다.
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        // This is the rect that we’ve calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

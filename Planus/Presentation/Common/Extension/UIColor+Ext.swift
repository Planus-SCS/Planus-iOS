//
//  UIColor+ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit

public extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
    }
    
    convenience init(hex: Int) {
        self.init(r: (hex & 0xff0000) >> 16, g: (hex & 0xff00) >> 8, b: (hex & 0xff), a: 1)
    }
    
    convenience init(hex: Int, a: CGFloat) {
        self.init(r: (hex & 0xff0000) >> 16, g: (hex & 0xff00) >> 8, b: (hex & 0xff), a: a)
    }
}

extension UIColor {
    static var planusBackgroundColor: UIColor {
        return UIColor(hex: 0xF5F5FB)
    }
    
    static var planusBlueGroundColor: UIColor {
        return UIColor(hex: 0xB2CAFA)
    }
    
    static var planusTintBlue: UIColor {
        return UIColor(hex: 0x6495F4)
    }
    
    static var planusDeepNavy: UIColor {
        return UIColor(hex: 0x6F81A9)
    }
    
    static var planusTintRed: UIColor {
        return UIColor(hex: 0xEA4335)
    }
    
    static var planusLightGray: UIColor {
        return UIColor(hex: 0xBFC7D7)
    }
    
    static var planusMediumGray: UIColor {
        return UIColor(hex: 0xADC5F8)
    }
    
    static var planusBlack: UIColor {
        return UIColor(hex: 0x000000)
    }
    
    static var planusWhite: UIColor {
        return UIColor(hex: 0xFFFFFF)
    }
    
    static var planusPlaceholderColor: UIColor {
        return UIColor(hex: 0x7A7A7A)
    }
}

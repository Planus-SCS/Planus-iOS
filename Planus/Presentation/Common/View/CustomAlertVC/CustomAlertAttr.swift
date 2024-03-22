//
//  CustomAlertAttr.swift
//  Planus
//
//  Created by Sangmin Lee on 3/19/24.
//

import UIKit

struct CustomAlertAttr {
    var title: String
    var actionHandler: () -> Void
    var type: AlertType
}

enum AlertType {
    case normal
    case warning
    
    var textColor: UIColor {
        switch self {
        case .normal:
            return UIColor(hex: 0x3D458A)
        case .warning:
            return .systemPink
        }
    }
}

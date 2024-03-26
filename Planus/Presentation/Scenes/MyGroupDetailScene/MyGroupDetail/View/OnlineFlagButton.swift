//
//  OnlineFlagButton.swift
//  Planus
//
//  Created by Sangmin Lee on 3/27/24.
//

import UIKit

final class OnlineFlagButton: UIButton {
    
    private let onImage = UIImage(named: "onlineEnabledFlag")
    private let offImage = UIImage(named: "onlineDisabledFlag")
    var isOn: Bool = false {
        didSet {
            let image = isOn ? onImage : offImage
            self.setImage(image, for: .normal)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

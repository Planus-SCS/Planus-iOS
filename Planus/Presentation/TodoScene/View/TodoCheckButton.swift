//
//  TodoCheckButton.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/25.
//

import UIKit

class TodoCheckButton: SpringableButton {
    
    var onImage: UIImage? = {
        let image = UIImage(named: "checkedBox")
        return image?.withRenderingMode(.alwaysTemplate)
    }()
    
    var offImage: UIImage? = {
        let image = UIImage(named: "uncheckedBox")
        return image?.withRenderingMode(.alwaysTemplate)
    }()
    
    var checkImageView: UIImageView = {
        var image = UIImage(named: "todoCheck")
        image = image?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image?.size.width ?? 0, height: image?.size.height ?? 0))
        imageView.image = image
        return imageView
    }()
    
    var isOn: Bool = false {
        didSet {
            if isOn {
                checkImageView.isHidden = false
                self.setImage(onImage, for: .normal)
            } else {
                checkImageView.isHidden = true
                self.setImage(offImage, for: .normal)
            }
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setImage(offImage, for: .normal)
        self.addSubview(checkImageView)
        self.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        checkImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func tapped() {
        self.isOn = !isOn
        Vibration.medium.vibrate()
    }
    
    func setColor(color: CategoryColor) {
        self.tintColor = color.todoThickColor
        self.checkImageView.tintColor = color.todoCheckColor
    }
}

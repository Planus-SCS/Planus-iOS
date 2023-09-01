//
//  MyGroupInfoHeaderView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/28.
//

import UIKit

class OnlineFlagButton: UIButton {
    
    var onImage = UIImage(named: "onlineEnabledFlag")
    var offImage = UIImage(named: "onlineDisabledFlag")
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

class MyGroupInfoHeaderView: GroupIntroduceInfoHeaderView {
    var onlineButton: OnlineFlagButton = {
        let button = OnlineFlagButton(frame: .zero)
        button.isHiddenAtSkeleton = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        
        centerContentView.addSubview(onlineButton)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        onlineButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalTo(30)
            $0.height.equalTo(50)
            $0.trailing.equalToSuperview().inset(15)
        }
    }
    
    func fill(title: String, tag: String, memCount: String, captin: String, onlineCount: String? = nil, isOnline: Bool) {
        super.fill(title: title, tag: tag, memCount: memCount, captin: captin, onlineCount: onlineCount)
        onlineButton.isOn = isOnline
    }
}

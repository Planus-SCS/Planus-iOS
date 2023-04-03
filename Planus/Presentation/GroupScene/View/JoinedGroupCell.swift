//
//  JoinedGroupCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/31.
//

import UIKit

class JoinedGroupCell: SearchResultCell {

    var chatButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("바로가기", for: .normal)
        button.backgroundColor = UIColor(hex: 0x000000, a: 0.7)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        button.setImage(UIImage(named: "messageIcon"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 12)
        button.imageEdgeInsets = .init(top: 0, left: -4, bottom: 0, right: 4)
        button.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        return button
    }()
    
    var onlineButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("3", for: .normal)
        button.backgroundColor = UIColor(hex: 0x000000, a: 0.7)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        button.setImage(UIImage(named: "onlineIcon"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 12)
        button.imageEdgeInsets = .init(top: 0, left: -4, bottom: 0, right: 4)
        button.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        return button
    }()
    
    lazy var onlineSwitch: UISwitch = {
        // Create a Switch.
        let swicth: UISwitch = UISwitch()
        
        // Display the border of Swicth.
        swicth.tintColor = UIColor.orange
        
        // Set Switch to On.
        swicth.isOn = false
        
        // Set the event to be called when switching On / Off of Switch.
        /*For on state*/
        swicth.onTintColor = UIColor(hex: 0x6495F4)

        /*For off state*/
        swicth.tintColor = UIColor(hex: 0x6F81A9)
        swicth.layer.cornerRadius = 14
        swicth.backgroundColor = UIColor(hex: 0x6F81A9)
        swicth.clipsToBounds = true
        
        return swicth
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
        
        self.addSubview(onlineButton)
        self.addSubview(chatButton)
        self.addSubview(onlineSwitch)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        onlineButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(12)
            $0.width.lessThanOrEqualToSuperview().dividedBy(2).offset(-12)
            $0.height.equalTo(26)
        }
        
        onlineSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalTo(onlineButton)
        }
        
        chatButton.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.leading.equalToSuperview().inset(12)
            $0.bottom.equalTo(bottomContentsView.snp.top).offset(-10)
            $0.trailing.lessThanOrEqualToSuperview().inset(12)
        }
    }
    
    func fill(title: String, tag: String?, memCount: String, captin: String, onlineCount: String, image: String) {
        super.fill(title: title, tag: tag, memCount: memCount, captin: captin)
        super.fill(image: UIImage(named: image))
        
        onlineButton.setTitle(onlineCount, for: .normal)
    }
}

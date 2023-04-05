//
//  MyGroupMemberEditCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit

class MyGroupMemberEditCell: GroupIntroduceMemberCell {

    var resignButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = UIColor(hex: 0xF9E3E9)
        button.setTitle("탈퇴", for: .normal)
        button.setTitleColor(UIColor(hex: 0xFF0000), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
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
        self.addSubview(resignButton)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        resignButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(64)
            $0.height.equalTo(28)
        }
        
        memberIntroduceLabel.snp.updateConstraints {
            $0.trailing.equalTo(resignButton.snp.leading).offset(-10)
        }
    }
}

//
//  MyGroupMemberEditCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit
import RxSwift

class MyGroupMemberEditCell: GroupIntroduceMemberCell {
    
    var buttonActionClosure: (() -> Void)?

    lazy var resignButton: SpringableButton = {
        let button = SpringableButton(frame: .zero)
        button.backgroundColor = UIColor(hex: 0xF9E3E9)
        button.setTitle("탈퇴", for: .normal)
        button.setTitleColor(UIColor(hex: 0xFF0000), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        button.addTarget(self, action: #selector(resignBtnAction), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
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
        memberIntroduceLabel.snp.remakeConstraints {
            $0.leading.equalTo(memberImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(resignButton.snp.leading).offset(-10)
            $0.top.equalTo(memberNameLabel.snp.bottom).offset(6)
            $0.height.equalTo(17)
        }

    }
    
    override func fill(name: String, introduce: String?, isCaptin: Bool, imgFetcher: Single<Data>) {
        super.fill(name: name, introduce: introduce, isCaptin: isCaptin, imgFetcher: imgFetcher)
        resignButton.isHidden = isCaptin
    }
    
    func fill(closure: @escaping () -> Void) {
        self.buttonActionClosure = closure
    }
    
    @objc func resignBtnAction(_ sender: UIButton) {
        buttonActionClosure?()
    }
}

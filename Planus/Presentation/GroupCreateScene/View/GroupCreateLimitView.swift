//
//  GroupCreateLimitView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import UIKit

class GroupCreateLimitView: UIView {
    var limitTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹 인원을 설정하세요"
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        return label
    }()
    
    var limitDescLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "숫자를 클릭하여 입력하세요"
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()
    
    var limitField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        
        textField.textAlignment = .center
        textField.addSidePadding(padding: 10)

        textField.attributedPlaceholder = NSAttributedString(
            string: "50",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x7A7A7A)]
        )
        
        textField.keyboardType = .numberPad
        return textField
    }()
    
    var limitLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "명"
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }()
    
    var maxLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "최대 인원"
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }()
    
    var fiftyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "50명"
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(limitTitleLabel)
        self.addSubview(limitDescLabel)
        self.addSubview(limitField)
        self.addSubview(limitLabel)
        self.addSubview(maxLabel)
        self.addSubview(fiftyLabel)
    }
    
    func configureLayout() {
        limitTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        limitDescLabel.snp.makeConstraints {
            $0.top.equalTo(limitTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(20)
        }
        
        limitField.snp.makeConstraints {
            $0.top.equalTo(limitDescLabel.snp.bottom).offset(12)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        
        limitLabel.snp.makeConstraints {
            $0.centerY.equalTo(limitField)
            $0.leading.equalTo(limitField.snp.trailing).offset(8)
        }
        
        maxLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(limitField.snp.bottom).offset(12)
        }
        
        fiftyLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(limitField.snp.bottom).offset(12)
            $0.bottom.equalToSuperview().inset(30)
        }
    }
}

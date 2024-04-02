//
//  GroupCreateLimitView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import UIKit
import RxSwift

class GroupCreateLimitView: UIView {
    var didChangedLimitValue = PublishSubject<String?>()
    var limitTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹 인원을 설정하세요"
        label.textColor = .planusBlack
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        return label
    }()
    
    var limitDescLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "숫자를 클릭하여 입력하세요"
        label.textColor = .planusDeepNavy
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()
    
    lazy var limitField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .planusBlack
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .planusWhite
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.planusDeepNavy.cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        
        textField.textAlignment = .center
        textField.addSidePadding(padding: 10)

        textField.attributedPlaceholder = NSAttributedString(
            string: "50",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor.planusPlaceholderColor]
        )
        
        textField.keyboardType = .numberPad
        textField.delegate = self
        return textField
    }()
    
    var limitLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "명"
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        label.textColor = .planusDeepNavy
        return label
    }()
    
    var maxLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "최대 인원"
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = .planusDeepNavy
        return label
    }()
    
    var fiftyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "50명"
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = .planusDeepNavy
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

extension GroupCreateLimitView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.limitField {
            if string == "" { //backspace
                if var textString = textField.text,
                   !textString.isEmpty {
                    textString = String(textString.dropLast())
                    textField.text = textString
                    didChangedLimitValue.onNext(textString)
                }
                return false
            } else if var textString = textField.text {
                if textString.count == 2 { //추가해서 세글자가 되면? 없애야함
                    return false
                }
                textString += string

                textField.text = textString
                didChangedLimitValue.onNext(textString)

                return false
            }
        }
        return true
    }
}

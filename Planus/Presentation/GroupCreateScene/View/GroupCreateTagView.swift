//
//  GroupCreateTagView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import UIKit
import RxSwift

class GroupCreateTagView: UIView {
    var bag = DisposeBag()
    var keyWordTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹과 관련된 키워드를 입력하세요"
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        return label
    }()
    
    var keyWordDescLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "박스 클릭 후 글자를 입력하세요"
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()
    
    lazy var tagField1: UITextField = self.textFieldGenerator(isMustField: true)
    lazy var tagField2: UITextField = self.textFieldGenerator(isMustField: false)
    lazy var tagField3: UITextField = self.textFieldGenerator(isMustField: false)
    lazy var tagField4: UITextField = self.textFieldGenerator(isMustField: false)
    lazy var tagField5: UITextField = self.textFieldGenerator(isMustField: false)

    lazy var tagFirstStack: UIStackView = self.horizontalStackGenerator()
    lazy var tagSecondStack: UIStackView = self.horizontalStackGenerator()
    
    lazy var tagCountValidateLabel: UILabel = self.validationLabelGenerator(text: "태그는 최대 5개까지 입력할 수 있어요")
    var tagCountCheckView: ValidationCheckImageView = .init()

    lazy var stringCountValidateLabel: UILabel = self.validationLabelGenerator(text: "한번에 최대 7자 이하만 적을 수 있어요")
    var stringCountCheckView: ValidationCheckImageView = .init()
    
    lazy var charcaterValidateLabel: UILabel = self.validationLabelGenerator(text: "띄어쓰기, 특수 문자는 빼주세요")
    var charValidateCheckView: ValidationCheckImageView = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(keyWordTitleLabel)
        self.addSubview(keyWordDescLabel)
        self.addSubview(tagField1)
        tagField1.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        
        self.addSubview(tagFirstStack)
        tagFirstStack.addArrangedSubview(tagField2)
        tagFirstStack.addArrangedSubview(tagField3)
        
        self.addSubview(tagSecondStack)
        tagSecondStack.addArrangedSubview(tagField4)
        tagSecondStack.addArrangedSubview(tagField5)
        
        self.addSubview(tagCountValidateLabel)
        self.addSubview(stringCountValidateLabel)
        self.addSubview(charcaterValidateLabel)
        
        self.addSubview(tagCountCheckView)
        self.addSubview(stringCountCheckView)
        self.addSubview(charValidateCheckView)
    }
    
    func configureLayout() {
        keyWordTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        keyWordDescLabel.snp.makeConstraints {
            $0.top.equalTo(keyWordTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(20)
        }
        
        tagField1.snp.makeConstraints {
            $0.top.equalTo(keyWordDescLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(40)
            $0.width.greaterThanOrEqualTo(100)
            $0.width.lessThanOrEqualToSuperview().offset(-40)
        }
        
        tagFirstStack.snp.makeConstraints {
            $0.top.equalTo(tagField1.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        tagField2.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(100)
            $0.width.lessThanOrEqualTo(tagFirstStack.snp.width).offset(-50)
        }

        tagField3.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(100)
            $0.width.lessThanOrEqualTo(tagFirstStack.snp.width).offset(-50)
        }
        tagSecondStack.snp.makeConstraints {
            $0.top.equalTo(tagFirstStack.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        tagField4.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(100)
            $0.width.lessThanOrEqualTo(tagSecondStack.snp.width).offset(-50)
        }

        tagField5.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(100)
            $0.width.lessThanOrEqualTo(tagSecondStack.snp.width).offset(-50)
        }
        
        tagCountValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagField4.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tagCountCheckView.snp.makeConstraints {
            $0.centerY.equalTo(tagCountValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        stringCountValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagCountValidateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        stringCountCheckView.snp.makeConstraints {
            $0.centerY.equalTo(stringCountValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        charcaterValidateLabel.snp.makeConstraints {
            $0.top.equalTo(stringCountValidateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().inset(30)
        }
        
        charValidateCheckView.snp.makeConstraints {
            $0.centerY.equalTo(charcaterValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    func textFieldGenerator(isMustField: Bool) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.addLeftPadding(padding: 10)
        textField.clearButtonMode = .always
        
        if isMustField {
            textField.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
            textField.attributedPlaceholder = NSAttributedString(
                string: "필수태그",
                attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x6F81A9)]
            )
        } else {
            textField.rx.text.asObservable()
                .subscribe(onNext: { text in
                    if text?.isEmpty ?? true {
                        textField.layer.borderColor = UIColor(hex: 0xBFC7D7).cgColor
                    } else {
                        textField.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
                    }
                })
                .disposed(by: bag)
            textField.attributedPlaceholder = NSAttributedString(
                string: "선택태그",
                attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBFC7D7)]
            )
        }
//
        return textField
    }
    
    func horizontalStackGenerator() -> UIStackView {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }
    
    func validationLabelGenerator(text: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = text
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }
}


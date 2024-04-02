//
//  GroupCreateInfoView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import UIKit
import RxSwift

class GroupCreateInfoView: UIView {

    var groupIntroduceTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹 소개를 입력해주세요"
        label.textColor = .planusBlack
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        return label
    }()
    
    var groupIntroduceDescLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹 사진, 이름, 소개는 필수입력 정보입니다."
        label.textColor = .planusDeepNavy
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()
        
    var groupImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.planusDeepNavy.cgColor
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "GroupCreateDefaultImage")
        return imageView
    }()
    
    var groupImageButton: SpringableButton = {
        let button = SpringableButton(frame: .zero)
        button.setImage(UIImage(named: "cameraBtn"), for: .normal)
        return button
    }()
    
    lazy var groupNameField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .planusBlack
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .planusWhite
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.planusDeepNavy.cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.addSidePadding(padding: 10)
        textField.attributedPlaceholder = NSAttributedString(
            string: "그룹 이름을 입력하세요",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor.planusPlaceholderColor]
        )
        textField.delegate = self

        return textField
    }()
    
    lazy var groupNoticeTextView: PlaceholderTextView = {
        let textView = PlaceholderTextView(frame: .zero)
        textView.isScrollEnabled = true
        textView.placeholder = "간단한 그룹소개 및 공지사항을 입력해주세요"
        textView.textColor = .planusBlack
        textView.backgroundColor = .planusWhite
        textView.font = UIFont(name: "Pretendard-Regular", size: 16)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        textView.placeholderColor = .planusPlaceholderColor
        textView.backgroundColor = .planusWhite
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.planusDeepNavy.cgColor
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        textView.delegate = self
        return textView
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
        self.addSubview(groupIntroduceTitleLabel)
        self.addSubview(groupIntroduceDescLabel)
        self.addSubview(groupImageView)
        self.addSubview(groupImageButton)
        self.addSubview(groupNameField)
        self.addSubview(groupNoticeTextView)
    }
    
    func configureLayout() {
        groupIntroduceTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(24)
        }
        
        groupIntroduceDescLabel.snp.makeConstraints {
            $0.top.equalTo(groupIntroduceTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(24)
        }
        
        groupImageView.snp.makeConstraints {
            $0.top.equalTo(groupIntroduceDescLabel.snp.bottom).offset(20)
            $0.width.height.equalTo(120)
            $0.centerX.equalToSuperview()
        }
        
        groupImageButton.snp.makeConstraints {
            $0.width.height.equalTo(34)
            $0.trailing.equalTo(groupImageView.snp.trailing).offset(10)
            $0.bottom.equalTo(groupImageView.snp.bottom).offset(10)
        }
        
        groupNameField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(groupImageView.snp.bottom).offset(20)
            $0.height.equalTo(45)
        }
        
        groupNoticeTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(groupNameField.snp.bottom).offset(10)
            $0.height.equalTo(110)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
}

extension GroupCreateInfoView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == self.groupNoticeTextView {
            let newLength = (textView.text?.count)! + text.count - range.length
            return !(newLength > 1000)
        }
        return true
        
    }
}

extension GroupCreateInfoView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.groupNameField {
            let newLength = (textField.text?.count)! + string.count - range.length
            return !(newLength > 10)
        }
        return true
    }
}

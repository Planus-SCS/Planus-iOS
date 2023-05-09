//
//  GroupCreateInfoView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import UIKit

class GroupCreateInfoView: UIView {
    
    var groupIntroduceTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹 소개를 입력해주세요"
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        return label
    }()
    
    var groupIntroduceDescLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹 사진, 이름, 소개는 필수입력 정보입니다."
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()
    
    var isDescEditing = false
    
    var groupImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "GroupCreateDefaultImage")
        return imageView
    }()
    
    var groupImageButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "cameraBtn"), for: .normal)
        return button
    }()
    
    var groupNameField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.addSidePadding(padding: 10)
        textField.attributedPlaceholder = NSAttributedString(
            string: "그룹 이름을 입력하세요",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x7A7A7A)]
        )

        return textField
    }()
    
    lazy var groupNoticeTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isScrollEnabled = false
        textView.text = "간단한 그룹소개 및 공지사항을 입력해주세요"
        textView.textColor = UIColor(hex: 0xBFC7D7)
        textView.backgroundColor = .white
        textView.font = UIFont(name: "Pretendard-Light", size: 16)
        textView.textContainer.lineFragmentPadding = 10
        textView.backgroundColor = .white
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
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
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "간단한 그룹소개 및 공지사항을 입력해주세요"
            textView.textColor = UIColor(hex: 0x7A7A7A)
            isDescEditing = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !(isDescEditing) {
            textView.text = nil
            textView.textColor = .black
            isDescEditing = true
        }
    }
}

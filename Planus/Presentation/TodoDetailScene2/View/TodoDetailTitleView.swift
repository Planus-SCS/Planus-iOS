//
//  TodoDetailTitleView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/23.
//

import UIKit

class TodoDetailTitleView: UIView {
    var todoTitleField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "Pretendard-Regular", size: 20)
        textField.textColor = .black
        textField.placeholder = "일정을 입력하세요"
        return textField
    }()
    
    var categoryButton: CategoryButton = {
        let button = CategoryButton(frame: .zero)
        button.fill(title: nil, color: nil)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(todoTitleField)
        self.addSubview(categoryButton)
    }
    
    func configureLayout() {
        set2lines()
    }
    
    func set2lines() {
        categoryButton.categoryLabel.isHidden = false

        todoTitleField.snp.remakeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.height.equalTo(30)
            $0.leading.equalToSuperview().inset(19)
            $0.trailing.lessThanOrEqualToSuperview().inset(19)
        }
        
        categoryButton.snp.remakeConstraints {
            $0.top.equalTo(todoTitleField.snp.bottom).offset(5)
            $0.height.equalTo(30)
            $0.leading.equalToSuperview().inset(19)
            $0.trailing.lessThanOrEqualToSuperview().inset(19)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    func set1line() {
        categoryButton.categoryLabel.isHidden = true

        categoryButton.snp.remakeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.height.equalTo(30)
            $0.leading.equalToSuperview().inset(19)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        todoTitleField.snp.remakeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.height.equalTo(30)
            $0.leading.equalTo(categoryButton.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(19)
        }

    }
}

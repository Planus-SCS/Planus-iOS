//
//  CategoryButton.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/23.
//

import UIKit

class CategoryButton: UIButton {
    var categoryLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "카테고리 선택"
        label.font = UIFont(name: "Pretendard-Light", size: 16)
        label.textColor = .planusLightGray
        label.sizeToFit()
        label.isUserInteractionEnabled = false
        return label
    }()
    
    var categoryColorView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.cornerCurve = .continuous
        view.backgroundColor = .gray
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var stackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        categoryColorView.layer.cornerRadius = 6
    }
    
    func configureView() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(categoryColorView)
    }
    
    func configureLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        categoryLabel.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(200)
        }
        
        categoryColorView.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
    }
    
    func fill(title: String?, color: UIColor?) {
        if let title,
           let color {
            self.categoryLabel.text = title
            self.categoryLabel.textColor = .planusBlack
            self.categoryColorView.backgroundColor = color
        } else {
            self.categoryLabel.text = "카테고리 선택"
            self.categoryLabel.textColor = .planusLightGray
            self.categoryColorView.backgroundColor = .gray
        }
    }
}

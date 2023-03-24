//
//  SmallTodoView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit

class SmallTodoView: UIView {
    var leadingView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    var toDoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 10)
        return label
    }()
    
    convenience init(text: String, category: TodoCategory) {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        
        fill(text: text, category: category)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(leadingView)
        self.addSubview(toDoLabel)
    }
    
    func configureLayout() {
        leadingView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(2)
        }
        toDoLabel.snp.makeConstraints {
            $0.leading.equalTo(leadingView.snp.trailing).offset(2.5)
            $0.trailing.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
        }
    }
    
    func fill(text: String, category: TodoCategory) {
        self.toDoLabel.text = text
        self.backgroundColor = category.todoForCalendarColor
        self.leadingView.backgroundColor = category.todoLeadingColor
        self.toDoLabel.textColor = category.todoThickColor

    }
}

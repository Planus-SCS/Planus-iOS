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
        label.textAlignment = .center
        return label
    }()
    
    convenience init(frame: CGRect, text: String, categoryColor: CategoryColor, isComplete: Bool?) {
        self.init(frame: frame)
        
        fill(text: text, categoryColor: categoryColor, isComplete: isComplete)
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
        self.layer.cornerRadius = 3
        self.layer.cornerCurve = .continuous
        self.clipsToBounds = true
        self.addSubview(leadingView)
        self.addSubview(toDoLabel)
    }
    
    func configureLayout() {
        leadingView.frame = CGRect(x: 0, y: 0, width: 2, height: self.frame.height)
        toDoLabel.snp.makeConstraints {
            $0.leading.equalTo(leadingView.snp.trailing).offset(2.5)
            $0.trailing.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
        }
        toDoLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    // FIXME: 상의 후 소셜투두 Summary에도 isComplete 담겨오면 옵셔널 빼고 쓰자.!!!
    func fill(text: String, categoryColor: CategoryColor, isComplete: Bool?) {
        self.toDoLabel.text = text
        self.leadingView.backgroundColor = categoryColor.todoLeadingColor
        self.backgroundColor = categoryColor.todoForCalendarColor
        self.toDoLabel.textColor = categoryColor.todoThickColor
        
        if let isComplete,
           isComplete {
            self.leadingView.isHidden = true
        }

    }
}
//
//  MemberProfileCalendarHeaderView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit

class MemberProfileCalendarHeaderView: UIView {
    lazy var yearMonthButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("2020년 0월", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.setImage(UIImage(named: "downButton"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: -5)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)

        return button
    }()
    var weekStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.distribution = .fillEqually
        let dayOfTheWeek = ["월", "화", "수", "목", "금", "토", "일"]
        for i in 0..<7 {
            let label = UILabel()
            label.text = dayOfTheWeek[i]
            label.textAlignment = .center
            label.font = UIFont(name: "Pretendard-Regular", size: 12)
            stackView.addArrangedSubview(label)
        }
        return stackView
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
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.addSubview(yearMonthButton)
        self.addSubview(weekStackView)
    }
    
    func configureLayout() {
        yearMonthButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(19)
            $0.height.equalTo(16)
            $0.width.equalTo(120)
        }
        
        weekStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(yearMonthButton.snp.bottom).offset(20)
            $0.bottom.equalToSuperview()
        }
    }

}

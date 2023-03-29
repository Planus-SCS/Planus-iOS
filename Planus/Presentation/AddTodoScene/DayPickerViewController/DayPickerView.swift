//
//  DayPickerView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

final class DayPickerView: UIView {
    lazy var prevButton: UIButton = {
        let image = UIImage(named: "monthPickerLeft")
        let button = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let image = UIImage(named: "monthPickerRight")
        let button = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        return button
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0x000000)
        label.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        label.textAlignment = .center
        return label
    }()
    
    lazy var weekDaysStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        ["월", "화", "수", "목", "금", "토", "일"].forEach {
            let label = self.weekDayLabel(weekDay: $0)
            stackView.addArrangedSubview(label)
        }
        return stackView
    }()
    
    var dayPickerCollectionView: DayPickerCollectionView = {
        return DayPickerCollectionView(frame: .zero)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func weekDayLabel(weekDay: String) -> UILabel {
        let label = UILabel(frame: .zero)
        switch weekDay {
        case "일":
            label.textColor = UIColor(hex: 0xEA4335)
        case "토":
            label.textColor = UIColor(hex: 0x6495F4)
        default:
            label.textColor = .black
        }
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.text = weekDay
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }
    
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        
        self.addSubview(dateLabel)
        self.addSubview(prevButton)
        self.addSubview(nextButton)
        self.addSubview(weekDaysStackView)
        self.addSubview(dayPickerCollectionView)
    }
    
    func configureLayout() {
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(60)
        }
        
        prevButton.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.leading.equalTo(self.safeAreaLayoutGuide.snp.leading).offset(10)
        }
        
        nextButton.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing).offset(-10)
        }
        
        weekDaysStackView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom)
            $0.leading.equalTo(self.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(20)
        }
        dayPickerCollectionView.snp.makeConstraints {
            $0.top.equalTo(weekDaysStackView.snp.bottom)
            $0.leading.equalTo(self.snp.leading)
            $0.trailing.equalTo(self.snp.trailing)
            $0.bottom.equalToSuperview().offset(-15)
        }
    }
}

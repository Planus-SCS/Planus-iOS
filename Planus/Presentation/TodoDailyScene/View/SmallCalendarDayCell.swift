//
//  SmallCalendarDayCell.swift
//  calendarTest
//
//  Created by Sangmin Lee on 2023/03/20.
//

import UIKit

class SmallCalendarDayCell: UICollectionViewCell {
    
    static let reuseIdentifier = "small-calendar-day-cell"
    
    lazy var dayLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Bold", size: 12)
        label.textColor = .black
        label.textAlignment = .center
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height/2
    }
    
    func configureView() {
        self.addSubview(dayLabel)
    }
    
    func configureLayout() {
        dayLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func fill(day: String, state: MonthStateOfDay, isSelectedDay: Bool) {
        dayLabel.text = day
        switch state {
        case .prev:
            dayLabel.textColor = UIColor(hex: 0x000000, a: 0.4)
        case .current:
            print("selected? \(isSelectedDay)")
            dayLabel.textColor = isSelectedDay ? .white : .black
        case .following:
            dayLabel.textColor = UIColor(hex: 0xBFC7D7, a: 0.4)
        }
        self.backgroundColor = isSelectedDay ? UIColor(hex: 0x6495F4) : nil
    }
}

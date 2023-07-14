//
//  DayPickerCollectionViewCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

class DayPickerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "day-picker-collection-view-cell"
    
    lazy var dayLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Bold", size: 12)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    var leftHalfView: UIView = UIView(frame: .zero)
    var rightHalfView: UIView = UIView(frame: .zero)
    var highlightView: UIView = UIView(frame: .zero)
    
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
        self.highlightView.layer.cornerRadius = self.frame.height/2
    }
    
    func configureView() {
        self.addSubview(leftHalfView)
        self.addSubview(rightHalfView)
        self.addSubview(highlightView)
        highlightView.addSubview(dayLabel)
    }
    
    func configureLayout() {
        leftHalfView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(2)
        }
        
        rightHalfView.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(2)
        }
        
        highlightView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dayLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func fill(day: String, state: MonthStateOfDay, rangeState: DayPickerModelRangeState) {
        dayLabel.text = day
        switch state {
        case .prev:
            dayLabel.textColor = UIColor(hex: 0x000000, a: 0.4)
        case .current:
            dayLabel.textColor = .black
        case .following:
            dayLabel.textColor = UIColor(hex: 0xBFC7D7, a: 0.4)
        }
        print(rangeState)
        switch rangeState {
        case .only:
            self.highlightView.backgroundColor = UIColor(hex: 0x6495F4)
            self.leftHalfView.backgroundColor = nil
            self.rightHalfView.backgroundColor = nil
        case .start:
            self.highlightView.backgroundColor = UIColor(hex: 0x6495F4)
            self.leftHalfView.backgroundColor = nil
            self.rightHalfView.backgroundColor = UIColor(hex: 0xADC5F8)
        case .end:
            self.highlightView.backgroundColor = UIColor(hex: 0x6495F4)
            self.leftHalfView.backgroundColor = UIColor(hex: 0xADC5F8)
            self.rightHalfView.backgroundColor = nil
        case .inRange:
            self.leftHalfView.backgroundColor = UIColor(hex: 0xADC5F8)
            self.rightHalfView.backgroundColor = UIColor(hex: 0xADC5F8)
            self.highlightView.backgroundColor = nil
        case .none:
            self.highlightView.backgroundColor = nil
            self.leftHalfView.backgroundColor = nil
            self.rightHalfView.backgroundColor = nil
        }
    }
}

//
//  MonthPickerCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/27.
//

import UIKit

final class MonthPickerCell: SpringableCollectionViewCell {
    
    static let reuseIdentifier = "month-picker-cell"
    
    private let monthLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = .planusBlack
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        monthLabel.text = nil
        monthLabel.textColor = .planusBlack
        self.layer.borderWidth = 0
    }
    
    private func configureView() {
        self.layer.cornerRadius = 17
        self.layer.cornerCurve = .continuous
        self.layer.borderColor = UIColor.planusTintBlue.cgColor
        self.addSubview(monthLabel)
    }
    
    private func configureLayout() {
        monthLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func fill(month: String, isCurrent: Bool, isValid: Bool) {
        monthLabel.text = month
        if isCurrent {
            self.layer.borderWidth = 1
            self.monthLabel.textColor = .planusTintBlue
        }
        
        if !isValid {
            self.monthLabel.textColor = .lightGray
        }
        
        self.isUserInteractionEnabled = isValid
    }
}

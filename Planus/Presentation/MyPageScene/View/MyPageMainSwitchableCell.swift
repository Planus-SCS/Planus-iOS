//
//  MyPageMainSwitchableCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import UIKit
import SnapKit

final class MyPageMainSwitchableCell: UITableViewCell {
    
    private var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = .black
        label.sizeToFit()
        return label
    }()
    
    lazy var onSwitch: UISwitch = {
        let swicth: UISwitch = UISwitch()
        swicth.isOn = false
        swicth.onTintColor = UIColor(hex: 0x6495F4)
        swicth.tintColor = UIColor(hex: 0x6F81A9)
        swicth.layer.cornerRadius = 14
        swicth.backgroundColor = UIColor(hex: 0x6F81A9)
        swicth.clipsToBounds = true
        
        return swicth
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        onSwitch.isOn = false
    }
    
    private func configureView() {
        self.addSubview(titleLabel)
        self.addSubview(onSwitch)
    }
    
    private func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        onSwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    public func fill(title: String, isOn: Bool) {
        self.titleLabel.text = title
        self.onSwitch.isOn = isOn
    }
}

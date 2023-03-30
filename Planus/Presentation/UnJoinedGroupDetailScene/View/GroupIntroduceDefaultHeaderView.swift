//
//  GroupIntroduceDefaultHeaderView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupIntroduceDefaultHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "group-introduce-header-supplementary-view"

    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0x6495F4)
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        return label
    }()
    
    var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-SemiBold", size: 18)
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
    
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)

        self.addSubview(titleLabel)
        self.addSubview(descLabel)
    }
    
    func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.top.equalToSuperview().inset(8)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.leading.equalToSuperview().inset(24)
        }
    }
    
    func fill(title: String, description: String) {
        self.titleLabel.text = title
        self.descLabel.text = description
    }
}

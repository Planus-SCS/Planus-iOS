//
//  GroupIntroduceDefaultHeaderView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift

final class GroupIntroduceDefaultHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "group-introduce-header-supplementary-view"
    
    var buttonActionClosure: (() -> Void)?
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0x6495F4)
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.isSkeletonable = true
        return label
    }()
    
    var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        label.isSkeletonable = true
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
    
    func fill(title: String?, description: String?) {
        self.titleLabel.text = title
        self.descLabel.text = description
    }
}

// MARK: - configure
private extension GroupIntroduceDefaultHeaderView {
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.addSubview(titleLabel)
        self.addSubview(descLabel)
    }
    
    func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalToSuperview().inset(24)
            $0.height.equalTo(19)
            $0.width.greaterThanOrEqualTo(70).priority(999)
            $0.trailing.lessThanOrEqualToSuperview().inset(24).priority(1000)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.leading.equalToSuperview().inset(24)
            $0.height.equalTo(21)
            $0.width.greaterThanOrEqualTo(170).priority(999)
            $0.trailing.lessThanOrEqualToSuperview().inset(24).priority(1000)
        }
    }
}

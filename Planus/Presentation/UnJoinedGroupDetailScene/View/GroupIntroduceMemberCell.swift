//
//  GroupIntroduceMemberCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupIntroduceMemberCell: UICollectionViewCell {
    static let reuseIdentifier = "group-introduce-member-cell"

    var memberImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var memberNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        label.textColor = .black
        return label
    }()
    
    var captinIconView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        imageView.image = UIImage(named: "captinSmall")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var memberIntroduceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = UIColor(hex: 0x6F81A9)
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
        self.addSubview(memberImageView)
        self.addSubview(memberNameLabel)
        self.addSubview(memberIntroduceLabel)
        self.addSubview(captinIconView)
    }
    
    func configureLayout() {
        memberImageView.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        memberNameLabel.snp.makeConstraints {
            $0.leading.equalTo(memberImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.top.equalToSuperview().inset(4)
            $0.height.equalTo(20)
        }
        
        memberIntroduceLabel.snp.makeConstraints {
            $0.leading.equalTo(memberImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.top.equalTo(memberNameLabel.snp.bottom).offset(6)
            $0.height.equalTo(17)
        }
        
        captinIconView.snp.makeConstraints {
            $0.leading.equalTo(memberNameLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(memberNameLabel)
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    func fill(name: String, introduce: String, isCaptin: Bool) {
        memberNameLabel.text = name
        memberIntroduceLabel.text = introduce
        captinIconView.isHidden = !isCaptin
    }
    
    func fill(image: UIImage) {
        self.memberImageView.image = image
    }
}

//
//  MemberProfileHeaderView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit

class MemberProfileHeaderView: UIView {
    var bottomView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: 0xF5F5FB)
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    var profileImageShadowView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowRadius = 2
        return view
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.layer.cornerCurve = .continuous
        imageView.image = UIImage(named: "DefaultProfileMedium")

        return imageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        label.textAlignment = .center
        label.text = "이름름"
        return label
    }()
    
    var introduceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.numberOfLines = 3
        label.textAlignment = .left
        label.text = "자기소개자기소개자기소개자기소개자기소개자기소개자기소개자기소개자기소개자기소개자기소개자기소개자기소개자기소개자기소개자기소개..."
        return label
    }()
    
    var separateView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: 0xBFC7D7)
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        view.layer.shadowOpacity = 10
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowRadius = 2
        return view
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
        self.backgroundColor = UIColor(hex: 0xB2CAFA)
        self.addSubview(bottomView)
        self.addSubview(profileImageShadowView)
        profileImageShadowView.addSubview(profileImageView)
        bottomView.addSubview(nameLabel)
        bottomView.addSubview(introduceLabel)
        bottomView.addSubview(separateView)
    }
    
    func configureLayout() {
        bottomView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(44)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        profileImageShadowView.snp.makeConstraints {
            $0.width.height.equalTo(70)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(44)
        }
        
        profileImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(56)
            $0.centerX.equalToSuperview()
        }
        
        introduceLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(48)
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
        }
        
        separateView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
    }
    
}
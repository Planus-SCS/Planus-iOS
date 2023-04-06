//
//  MemberProfileViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit

// 애도 델리게이트 써서 위에 뷰를 작아지게 만들어야할듯? 하다 ㅋㅋ,,,,,,

class MemberProfileViewController: UIViewController {
    
}


class MemberProfileTopHeaderView: UIView {
    var bottomView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.layer.cornerCurve = .continuous
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        label.textAlignment = .center
        return label
    }()
    
    var introduceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.numberOfLines = 3
        label.textAlignment = .left
        return label
    }()
    
    var separateView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: 0xBFC7D7)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(bottomView)
        self.addSubview(profileImageView)
        bottomView.addSubview(nameLabel)
        bottomView.addSubview(introduceLabel)
        bottomView.addSubview(separateView)
    }
    
    func configureLayout() {
        bottomView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(44)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(70)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(44)
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
            $0.top.equalTo(introduceLabel.snp.bottom).offset(22)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
    }
    
}


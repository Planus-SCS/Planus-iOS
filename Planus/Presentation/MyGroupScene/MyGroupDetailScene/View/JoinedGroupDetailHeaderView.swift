//
//  JoinedGroupDetailHeaderView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit
import SnapKit

class JoinedGroupDetailHeaderView: UIView {
    
    var titleImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var tagLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.layer.masksToBounds = false
        label.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        label.layer.shadowOpacity = 1
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowRadius = 2
        return label
    }()
    
    var memberCountButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("4/18", for: .normal)
        button.backgroundColor = UIColor(hex: 0x000000, a: 0.7)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        button.setImage(UIImage(named: "peopleWhite"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 14)
        button.imageEdgeInsets = .init(top: 0, left: -4, bottom: 0, right: 4)
        button.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        return button
    }()
    
    var captinButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("3", for: .normal)
        button.backgroundColor = UIColor(hex: 0x000000, a: 0.7)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        button.setImage(UIImage(named: "captinSmall"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 14)
        button.imageEdgeInsets = .init(top: 0, left: -4, bottom: 0, right: 4)
        button.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        return button
    }()
    
    var onlineButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("4", for: .normal)
        button.backgroundColor = UIColor(hex: 0x000000, a: 0.7)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        button.setImage(UIImage(named: "onlineIcon"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 14)
        button.imageEdgeInsets = .init(top: 0, left: -4, bottom: 0, right: 4)
        button.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        return button
    }()
    
//    var memberProfileStack: UIStackView = {
//        let stackView = UIStackView(frame: .zero)
//        stackView.axis = .horizontal
//        stackView.spacing = -8
//        stackView.alignment = .center
//        return stackView
//    }()
    
//    var memberRemainingStack: UILabel = {
//        let label = UILabel(frame: .zero)
//        label.font = UIFont(name: "Pretendard-Regular", size: 14)
//        label.textColor = .white
//        label.text = "+1"
//        return label
//    }()
    
//    lazy var memberStackView: UIStackView = {
//        let stackView = UIStackView(frame: .zero)
//        stackView.axis = .horizontal
//        stackView.spacing = 4
//        stackView.alignment = .center
//        stackView.addArrangedSubview(memberProfileStack)
//        stackView.addArrangedSubview(memberRemainingStack)
//        return stackView
//    }()
    
    lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubview(memberCountButton)
        stackView.addArrangedSubview(onlineButton)
        stackView.addArrangedSubview(captinButton)
//        stackView.addArrangedSubview(memberStackView)

        return stackView
    }()
    
    lazy var onlineSwitch: UISwitch = {
        let swicth: UISwitch = UISwitch()
        swicth.tintColor = UIColor.orange
        swicth.isOn = false

        swicth.onTintColor = UIColor(hex: 0x6495F4)
        swicth.tintColor = UIColor(hex: 0x6F81A9)
        swicth.layer.cornerRadius = 14
        swicth.backgroundColor = UIColor(hex: 0x6F81A9)
        swicth.clipsToBounds = true
        
        return swicth
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
        self.clipsToBounds = true
        self.addSubview(titleImageView)
        self.addSubview(tagLabel)
        self.addSubview(bottomStackView)
        self.addSubview(onlineSwitch)
    }
    
    func configureLayout() {
        titleImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        memberCountButton.snp.makeConstraints {
            $0.height.equalTo(26)
        }
        
        captinButton.snp.makeConstraints {
            $0.height.equalTo(26)
        }
        
        onlineButton.snp.makeConstraints {
            $0.height.equalTo(26)
        }
        
//        memberStackView.snp.makeConstraints {
//            $0.height.equalTo(26)
//        }
//
//        memberProfileStack.snp.makeConstraints {
//            $0.height.equalTo(26)
//        }
        
        bottomStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().offset(-34)
            $0.height.equalTo(26)
            $0.bottom.equalToSuperview().inset(56)
        }
        
        onlineSwitch.snp.makeConstraints {
            $0.bottom.equalTo(bottomStackView.snp.top).offset(-26)
            $0.trailing.equalToSuperview().inset(17)
        }
        
        tagLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(156)
            $0.centerX.equalToSuperview()
            $0.width.lessThanOrEqualTo(300)
        }
    }
    
    func generateMemberProfileImageView(image: UIImage?) -> UIView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        imageView.image = image
        imageView.layer.cornerRadius = 12
        imageView.layer.cornerCurve = .continuous
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

}

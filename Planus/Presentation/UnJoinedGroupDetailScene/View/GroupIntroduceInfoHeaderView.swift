//
//  GroupIntroduceInfoCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupIntroduceInfoHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "group-introduce-info-header-supplementary-view"
    
    var titleImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var captinIconView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        imageView.image = UIImage(named: "captinSmall")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var captinNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = UIColor(hex: 0x6F81A9)
        label.sizeToFit()
        return label
    }()
    
    var captinStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    var memberIconView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        imageView.image = UIImage(named: "peopleSmall")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var memberCountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = UIColor(hex: 0x6F81A9)
        label.sizeToFit()
        return label
    }()
    
    var memberStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    var bottomStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Bold", size: 20)
        label.textColor = .black
        return label
    }()
    
    var tagLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "메모를 입력하세요"
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.numberOfLines = 2
        return label
    }()
    
    var centerContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
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
        self.backgroundColor = UIColor(hex: 0xF5F5FB)

        self.addSubview(titleImageView)
        
        self.addSubview(centerContentView)
        centerContentView.addSubview(titleLabel)
        centerContentView.addSubview(tagLabel)
        
        self.addSubview(memberStackView)
        memberStackView.addArrangedSubview(memberIconView)
        memberStackView.addArrangedSubview(memberCountLabel)
        
        self.addSubview(captinStackView)
        captinStackView.addArrangedSubview(captinIconView)
        captinStackView.addArrangedSubview(captinNameLabel)
        
        self.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(memberStackView)
        bottomStackView.addArrangedSubview(captinStackView)
    }
    
    func configureLayout() {
        titleImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(120)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
            $0.width.lessThanOrEqualToSuperview().offset(-20)
            $0.height.equalTo(20)
        }
        
        centerContentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(bottomStackView.snp.top).offset(-16)
            $0.height.equalTo(135)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(30)
            $0.width.lessThanOrEqualToSuperview().offset(-20)
        }
        
        tagLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.width.lessThanOrEqualToSuperview().offset(-20)
        }
        
        
    }
    
    func fill(title: String, tag: String, memCount: String, captin: String) {
        self.titleLabel.text = title
        self.tagLabel.text = tag
        self.memberCountLabel.text = memCount
        self.captinNameLabel.text = captin
    }
    
    func fill(image: UIImage) {
        self.titleImageView.image = image
    }
}

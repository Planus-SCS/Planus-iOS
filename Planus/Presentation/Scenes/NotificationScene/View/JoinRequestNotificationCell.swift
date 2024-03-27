//
//  JoinRequestNotificationCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/31.
//

import UIKit
import RxSwift
import RxCocoa

class GroupJoinNotificationCell: UICollectionViewCell {
    static let reuseIdentifier = "group-join-notification-cell"
    
    var bag: DisposeBag?
    var indexPath: IndexPath?
    var isAllowTapped: PublishRelay<Int?>?
    var isDenyTapped: PublishRelay<Int?>?
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "JoinNotificationProfile"))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.cornerCurve = .continuous
        imageView.contentMode = .scaleAspectFill
        imageView.isSkeletonable = true
        return imageView
    }()
    
    var groupTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Bold", size: 12)
        label.textColor = UIColor(hex: 0x6495F4)
        label.isSkeletonable = true
        return label
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        label.textColor = .black
        label.isSkeletonable = true
        return label
    }()
    
    var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = UIColor(hex: 0x6F81A9)
        label.isSkeletonable = true
        return label
    }()
    
    lazy var allowButton: SpringableButton = {
        let button = SpringableButton(frame: .zero)
        button.setTitle("수락", for: .normal)
        button.setTitleColor(UIColor(hex: 0x6495F4), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        button.backgroundColor = UIColor(hex: 0xD2E6F6)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: #selector(allowBtnTapped), for: .touchUpInside)
        button.isSkeletonable = true
        return button
    }()
    
    lazy var denyButton: SpringableButton = {
        let button = SpringableButton(frame: .zero)
        button.setTitle("거절", for: .normal)
        button.setTitleColor(UIColor(hex: 0xFF0000), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        button.backgroundColor = UIColor(hex: 0xF9E3E9)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: #selector(denyBtnTapped), for: .touchUpInside)
        button.isSkeletonable = true
        return button
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
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 2
        
        
        self.addSubview(profileImageView)
        self.addSubview(groupTitleLabel)
        self.addSubview(nameLabel)
        self.addSubview(descLabel)
        self.addSubview(allowButton)
        self.addSubview(denyButton)
    }
    
    func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.top.equalToSuperview().inset(14)
            $0.width.height.equalTo(54)
        }
        
        groupTitleLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(9)
            $0.trailing.lessThanOrEqualToSuperview().inset(9)
            $0.width.greaterThanOrEqualTo(90).priority(999)
            $0.height.equalTo(14)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(groupTitleLabel.snp.bottom).offset(2)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(9)
            $0.trailing.lessThanOrEqualToSuperview().inset(9)
            $0.width.greaterThanOrEqualTo(50).priority(999)
            $0.height.equalTo(19)
        }
        
        descLabel.snp.makeConstraints {
            $0.bottom.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(9)
            $0.trailing.equalToSuperview().inset(9)
            $0.height.equalTo(17)
        }
        
        allowButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.top.equalTo(profileImageView.snp.bottom).offset(6)
            $0.height.equalTo(28)
            $0.width.equalToSuperview().offset(-18).dividedBy(2)
        }
        
        denyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.top.equalTo(profileImageView.snp.bottom).offset(6)
            $0.height.equalTo(28)
            $0.width.equalToSuperview().dividedBy(2)
        }
    }
    
    @objc func allowBtnTapped(_ sender: UIButton) {
        isAllowTapped?.accept(indexPath?.item)
    }
    
    @objc func denyBtnTapped(_ sender: UIButton) {
        isDenyTapped?.accept(indexPath?.item)
    }
    
    func fill(
        bag: DisposeBag,
        indexPath: IndexPath,
        isAllowTapped: PublishRelay<Int?>,
        isDenyTapped: PublishRelay<Int?>
    ) {
        self.bag = bag
        self.indexPath = indexPath
        self.isAllowTapped = isAllowTapped
        self.isDenyTapped = isDenyTapped
    }
    
    func fill(groupName: String, memberName: String, memberDesc: String?) {
        groupTitleLabel.text = groupName
        nameLabel.text = memberName
        descLabel.text = memberDesc
    }
    
    func fill(memberImage: UIImage?) {
        profileImageView.image = memberImage
    }
}

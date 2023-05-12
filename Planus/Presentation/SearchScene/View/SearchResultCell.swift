//
//  SearchResultCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class SearchResultCell: UICollectionViewCell {
    
    static let reuseIdentifier = "search-result-cell"
    
    var titleImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var captinIconView: UIImageView = {
        let image = UIImage(named: "captinSmall")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var captinNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        label.sizeToFit()
        return label
    }()
    
    var captinStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    var memberIconView: UIImageView = {
        let image = UIImage(named: "peopleSmall")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var memberCountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        label.sizeToFit()
        return label
    }()
    
    var memberStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    var bottomContentsView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowRadius = 2
        return view
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Bold", size: 14)
        label.textColor = .black
        return label
    }()
    
    var tagLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "메모를 입력하세요"
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureShadow()
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        UIView.transition(with: titleImageView,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
            self.titleImageView.image = nil
        },
                          completion: nil)
        captinNameLabel.text = nil
        memberCountLabel.text = nil
        titleLabel.text = nil
        tagLabel.text = nil
    }
 
    func configureShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 5
    }
    
    func configureView() {
        self.addSubview(titleImageView)
        self.addSubview(bottomContentsView)
        bottomContentsView.addSubview(titleLabel)
        bottomContentsView.addSubview(tagLabel)
        bottomContentsView.addSubview(memberStackView)
        bottomContentsView.addSubview(captinStackView)
        memberStackView.addArrangedSubview(memberIconView)
        memberStackView.addArrangedSubview(memberCountLabel)
        captinStackView.addArrangedSubview(captinIconView)
        captinStackView.addArrangedSubview(captinNameLabel)
    }
    
    func configureLayout() {
        titleImageView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(self.snp.height).offset(-100)
        }
        
        bottomContentsView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(110)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(12)
            $0.height.equalTo(17)
        }
        
        tagLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        memberStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(7)
            $0.leading.equalToSuperview().inset(12)
            $0.height.equalTo(14)
            $0.width.lessThanOrEqualToSuperview().offset(-12).dividedBy(2)
        }
        
        captinStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(7)
            $0.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(14)
            $0.width.lessThanOrEqualToSuperview().offset(-12).dividedBy(2)
        }
        
    }
    
    func fill(title: String, tag: String?, memCount: String, captin: String) {
        self.titleLabel.text = title
        self.tagLabel.text = tag
        self.memberCountLabel.text = memCount
        self.captinNameLabel.text = captin
    }
    
    func fill(image: UIImage?) {
        UIView.transition(with: titleImageView,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
            self.titleImageView.image = image
            
        },
                          completion: nil)
    }
    
}


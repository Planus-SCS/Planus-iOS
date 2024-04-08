//
//  SearchResultCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift

class SearchResultCell: SpringableCollectionViewCell {
    
    static let reuseIdentifier = "search-result-cell"
    
    var bag: DisposeBag?
    
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
        return imageView
    }()
    
    var captinNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = .planusDeepNavy
        label.sizeToFit()
        return label
    }()
    
    var captinStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.isSkeletonable = true
        return stackView
    }()
    
    var memberIconView: UIImageView = {
        let image = UIImage(named: "peopleSmall")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    var memberCountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = .planusDeepNavy
        label.sizeToFit()
        return label
    }()
    
    var memberStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        
        stackView.spacing = 4
        stackView.isSkeletonable = true
        return stackView
    }()
    
    var bottomStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    var bottomContentsView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .planusWhite
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
        label.textColor = .planusBlack
        label.isSkeletonable = true
        return label
    }()
    
    var tagLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "메모를 입력하세요"
        label.textColor = .planusDeepNavy
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.numberOfLines = 2
        label.isSkeletonable = true
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

        titleImageView.image = nil
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
        bottomContentsView.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(memberStackView)
        bottomStackView.addArrangedSubview(captinStackView)
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
            $0.height.greaterThanOrEqualTo(14)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(7)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(14)
        }

        memberIconView.snp.makeConstraints {
            $0.width.height.equalTo(14)
        }
        
        captinIconView.snp.makeConstraints {
            $0.width.height.equalTo(14)
        }
    }
    
    func fill(title: String, tag: String?, memCount: String, captin: String, imgFetcher: Single<Data>) {
        self.titleLabel.text = title
        self.tagLabel.text = tag
        self.memberCountLabel.text = memCount
        self.captinNameLabel.text = captin
        
        let bag = DisposeBag()
        self.bag = bag
        
        imgFetcher
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] data in
                self?.fill(image: UIImage(data: data))
            })
            .disposed(by: bag)
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


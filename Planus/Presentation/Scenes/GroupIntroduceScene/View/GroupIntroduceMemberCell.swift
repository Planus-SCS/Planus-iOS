//
//  GroupIntroduceMemberCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift

class GroupIntroduceMemberCell: SpringableCollectionViewCell {
    static let reuseIdentifier = "group-introduce-member-cell"
    
    private var bag: DisposeBag?
    
    let memberImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerCurve = .continuous
        imageView.isSkeletonable = true
        return imageView
    }()
    
    let memberNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        label.textColor = .planusBlack
        label.isSkeletonable = true
        return label
    }()
    
    private let captinIconView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        imageView.image = UIImage(named: "captinSmall")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isHiddenAtSkeleton = true
        return imageView
    }()
    
    let memberIntroduceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = .planusDeepNavy
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        memberImageView.layer.cornerRadius = memberImageView.bounds.width/2
    }
    
    func configureView() {
        self.backgroundColor = .planusBackgroundColor
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
            $0.trailing.lessThanOrEqualToSuperview().priority(1000)
            $0.width.greaterThanOrEqualTo(20).priority(999)
            $0.top.equalToSuperview().inset(4)
            $0.height.equalTo(20)
        }
        
        memberIntroduceLabel.snp.makeConstraints {
            $0.leading.equalTo(memberImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(memberNameLabel.snp.bottom).offset(6)
            $0.height.equalTo(17)
        }
        
        captinIconView.snp.makeConstraints {
            $0.leading.equalTo(memberNameLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(memberNameLabel)
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    func fill(name: String, introduce: String?, isCaptin: Bool, imgFetcher: Single<Data>) {
        memberNameLabel.text = name
        memberIntroduceLabel.text = introduce
        captinIconView.isHidden = !isCaptin
        
        let bag = DisposeBag()
        self.bag = bag
        imgFetcher
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] data in
                self?.fill(image: UIImage(data: data))
            }, onFailure: { [weak self] _ in
                self?.fill(image: UIImage(named: "DefaultProfileMedium"))
            })
            .disposed(by: bag)
    }
    
    func fill(image: UIImage?) {
        self.memberImageView.image = image
    }
}

//
//  MyGroupCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/31.
//

import UIKit
import RxSwift

final class MyGroupCell: SearchResultCell {
    
    var outerSwitchBag: DisposeBag?
    private var indexPath: IndexPath?
    
    private var isOnline = PublishSubject<Bool>()

    private let chatButton: SpringableButton = {
        let button = SpringableButton(frame: .zero)
        button.setTitle("바로가기", for: .normal)
        button.backgroundColor = .planusBlack.withAlphaComponent(0.7)
        button.setTitleColor(.planusWhite, for: .normal)
        button.setImage(UIImage(named: "messageIcon"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 12)
        button.imageEdgeInsets = .init(top: 0, left: -4, bottom: 0, right: 4)
        button.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.isSkeletonable = true
        return button
    }()
    
    let onlineButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("3", for: .normal)
        button.backgroundColor = .planusBlack.withAlphaComponent(0.7)
        button.setTitleColor(.planusWhite, for: .normal)
        button.setImage(UIImage(named: "onlineIcon"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 12)
        button.imageEdgeInsets = .init(top: 0, left: -4, bottom: 0, right: 4)
        button.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.isSkeletonable = true
        return button
    }()
    
    lazy var onlineSwitch: UISwitch = {
        let swicth: UISwitch = UISwitch()
        swicth.tintColor = UIColor.orange
        swicth.isOn = false

        swicth.onTintColor = .planusTintBlue
        swicth.tintColor = .planusDeepNavy
        swicth.layer.cornerRadius = 14
        swicth.backgroundColor = .planusDeepNavy
        swicth.clipsToBounds = true
        swicth.isSkeletonable = true
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        onlineButton.setTitle("0", for: .normal)
    }
    
    override func configureView() {
        super.configureView()
        
        self.addSubview(onlineButton)
        self.addSubview(onlineSwitch)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        onlineButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(12)
            $0.width.lessThanOrEqualToSuperview().dividedBy(2).offset(-12)
            $0.height.equalTo(26)
        }
        
        onlineSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalTo(onlineButton)
        }
    }
    
    func fill(title: String, tag: String?, memCount: String, leaderName: String, onlineCount: String, isOnline: Bool, imgFetcher: Single<Data>) {
        super.fill(title: title, tag: tag, memCount: memCount, captin: leaderName, imgFetcher: imgFetcher)
        onlineButton.setTitle(onlineCount, for: .normal)
        onlineSwitch.isOn = isOnline
    }
}

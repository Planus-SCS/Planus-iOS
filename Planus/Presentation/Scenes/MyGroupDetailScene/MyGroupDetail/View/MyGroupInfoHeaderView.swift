//
//  MyGroupInfoHeaderView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/28.
//

import UIKit
import RxSwift
import RxCocoa

final class MyGroupInfoHeaderView: GroupIntroduceInfoHeaderView {
    private let onlineButton: OnlineFlagButton = {
        let button = OnlineFlagButton(frame: .zero)
        button.isHiddenAtSkeleton = true
        return button
    }()
    
    private let onlineIconView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        imageView.image = UIImage(named: "onlineSmall")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let onlineCountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = UIColor(hex: 0x6F81A9)
        label.sizeToFit()
        return label
    }()
    
    private let onlineStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureView()
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        
        centerContentView.addSubview(onlineButton)
        
        onlineStackView.addArrangedSubview(onlineIconView)
        onlineStackView.addArrangedSubview(onlineCountLabel)

        bottomStackView.insertArrangedSubview(onlineStackView, at: 1)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        onlineButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalTo(30)
            $0.height.equalTo(50)
            $0.trailing.equalToSuperview().inset(15)
        }
    }
    
    func fill(
        title: String,
        tag: String,
        memCount: String,
        captin: String,
        onlineCount: String,
        isOnline: Bool,
        imgFetcher: Single<Data>,
        onlineBtnTapped: PublishRelay<Void>
    ) {
        super.fill(title: title, tag: tag, memCount: memCount, captin: captin, imgFetcher: imgFetcher)
        onlineButton.isOn = isOnline
        onlineCountLabel.text = onlineCount
        
        guard let bag else { return }
        onlineButton
            .rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { v, _ in
                v.onlineButton.isOn = !v.onlineButton.isOn
                onlineBtnTapped.accept(())
            })
            .disposed(by: bag)        
    }
    
    func onlineStatusChanged(count: String, isOn: Bool) {
        onlineButton.isOn = isOn
        onlineCountLabel.text = String(count)
    }
}

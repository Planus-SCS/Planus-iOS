//
//  MyPageMainSwitchableCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import UIKit
import SnapKit
import RxSwift

final class MyPageMainSwitchableCell: UICollectionViewCell {
    
    static let reuseIdentifier = "my-page-main-switchable-cell"
    
    private var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = .planusBlack
        label.sizeToFit()
        return label
    }()
    
    lazy var onSwitch: UISwitch = {
        let swicth: UISwitch = UISwitch()
        swicth.isOn = false
        swicth.onTintColor = .planusTintBlue
        swicth.tintColor = .planusDeepNavy
        swicth.layer.cornerRadius = 14
        swicth.backgroundColor = .planusDeepNavy
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        onSwitch.isOn = false
    }
    
    private func configureView() {
        self.backgroundColor = .planusBackgroundColor
        self.addSubview(titleLabel)
        self.addSubview(onSwitch)
    }
    
    private func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        onSwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    public func fill(title: String, isOn: BehaviorSubject<Bool>, pushSwitchBag: DisposeBag) {
        self.titleLabel.text = title
        
        // 양방향으로 바인딩하자... 네트워크에서 받아와서 뿌려주는거는 양방향 바인딩을 다 써도 되는건가?
        isOn
            .bind(to: onSwitch.rx.isOn)
            .disposed(by: pushSwitchBag)

        onSwitch.rx.isOn
            .bind(to: isOn)
            .disposed(by: pushSwitchBag)
    }
}

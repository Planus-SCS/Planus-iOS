//
//  GroupIntroduceDefaultHeaderView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift

class GroupIntroduceDefaultHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "group-introduce-header-supplementary-view"
    
    // index를 넣어두고 버튼 탭을 처리해야하나? 아니면 클로저를 넣어둘까? 클로저로 가는게 좋을듯함..!
    var buttonActionClosure: (() -> Void)?

    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0x6495F4)
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        return label
    }()
    
    var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        return label
    }()
    
    var editButton: UIButton = {
        let image = UIImage(named: "editBlack") ?? UIImage()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(editBtnTapped), for: .touchUpInside)
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
        self.backgroundColor = UIColor(hex: 0xF5F5FB)

        self.addSubview(titleLabel)
        self.addSubview(descLabel)
        self.addSubview(editButton)
    }
    
    func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.top.equalToSuperview().inset(8)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.leading.equalToSuperview().inset(24)
        }
        
        editButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(descLabel)
        }
    }
    
    func fill(title: String, description: String, isCaptin: Bool) {
        self.titleLabel.text = title
        self.descLabel.text = description
        editButton.isHidden = !isCaptin
    }
    
    func fill(closure: @escaping () -> Void) {
        self.buttonActionClosure = closure
    }
    
    @objc func editBtnTapped(_ sender: UIButton) {
        buttonActionClosure?()
    }
}

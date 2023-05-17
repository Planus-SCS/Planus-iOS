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
    
    var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.spacing = 3
        return stackView
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
        self.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descLabel)
    }
    
    func configureLayout() {
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }
    }
    
    func fill(title: String, description: String) {
        self.titleLabel.text = title
        self.descLabel.text = description
    }

}

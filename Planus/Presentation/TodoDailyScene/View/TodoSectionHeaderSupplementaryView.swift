//
//  TodoSectionHeaderSupplementaryView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit

class TodoSectionHeaderSupplementaryView: UICollectionReusableView {
    static let reuseIdentifier = "todo-section-header-supplementary-view"
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.font = UIFont(name: "Pretendard-Bold", size: 18)
        label.textAlignment = .center
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
    
    func configureView() {
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous
        self.addSubview(titleLabel)
    }
    
    func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(4)
        }
    }
    
    func fill(title: String) {
        titleLabel.text = title
    }
}

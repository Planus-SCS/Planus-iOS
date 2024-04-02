//
//  MyPageMainSelectableCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/25.
//

import UIKit
import SnapKit
import RxSwift

final class MyPageMainSelectableCell: SpringableCollectionViewCell {
    
    static let reuseIdentifier = "my-page-main-selectable-cell"
    
    private var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = .planusBlack
        label.sizeToFit()
        return label
    }()
    
    lazy var symbolView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "smallArrow"))
        return imageView
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
    }
    
    private func configureView() {
        self.backgroundColor = .planusBackgroundColor
        self.addSubview(titleLabel)
        self.addSubview(symbolView)
    }
    
    private func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        symbolView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    public func fill(title: String) {
        self.titleLabel.text = title
    }
}

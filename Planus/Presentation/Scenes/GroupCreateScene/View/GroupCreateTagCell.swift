//
//  GroupCreateTagCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/19.
//

import UIKit

class GroupCreateTagCell: SpringableCollectionViewCell {
    static let reuseIdentifier = "group-create-tag-cell"

    var removeBtnClosure: (() -> Void)?
    
    var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Bold", size: 14)
        label.textColor = .planusWhite
        return label
    }()
    
    lazy var removeButton: UIButton = {
        let image = UIImage(named: "removeBtn") ?? UIImage()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(removeBtnTapped), for: .touchUpInside)
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
        self.backgroundColor = .planusTintBlue
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous
        
        self.contentView.addSubview(label)
        self.contentView.addSubview(removeButton)
    }
    
    func configureLayout() {
        removeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }
        
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
            $0.trailing.equalTo(removeButton.snp.leading).offset(-6)
        }
    }
    
    func fill(tag: String) {
        self.label.text = tag
        label.invalidateIntrinsicContentSize()
    }
    
    @objc func removeBtnTapped(_ sender: UIButton) {
        removeBtnClosure?()
    }
}

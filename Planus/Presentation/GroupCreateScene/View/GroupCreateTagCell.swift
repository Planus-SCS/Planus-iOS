//
//  GroupCreateTagCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/19.
//

import UIKit

class GroupCreateTagCell: UICollectionViewCell {
    var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = .white
        return label
    }()
    
    var removeButton: UIButton = {
        let image = UIImage(named: "removeBtn") ?? UIImage()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        button.setImage(image, for: .normal)
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
        self.addSubview(label)
        self.addSubview(removeButton)
    }
    
    func configureLayout() {
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
        }
        
        removeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(label.snp.trailing).offset(6)
        }
    }
    
    func fill(tag: String) {
        self.label.text = tag
    }
}

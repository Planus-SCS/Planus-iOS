//
//  GroupCreateTagAddCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/19.
//

import UIKit

class GroupCreateTagAddCell: UICollectionViewCell {
    static let reuseIdentifier = "group-create-tag-add-cell"
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.07, delay: 0, options: .curveEaseIn, animations: {
                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                })
            } else {
                UIView.animate(withDuration: 0.07, delay: 0, options: .curveEaseOut, animations: {
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            }
        }
    }
    
    var imageView: UIImageView = {
        let image = UIImage(named: "whitePlusBtn")
        return UIImageView(image: image)
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
        self.backgroundColor = UIColor(hex: 0x6495F4)
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous
        self.addSubview(imageView)
    }
    
    func configureLayout() {
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(14)
        }
    }
}

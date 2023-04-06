//
//  CategoryCreateCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

class CategoryCreateCell: UICollectionViewCell {
    static let reuseIdentifier = "category-create-cell"
    
    let checkImageView: UIImageView = {
        let image = UIImage(named: "categoryCheck")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.checkImageView.isHidden = false
            } else {
                self.checkImageView.isHidden = true
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.checkImageView.isHidden = true
    }
    
    func configureView() {
        self.layer.cornerRadius = 5
        self.layer.cornerCurve = .continuous
        
        self.addSubview(checkImageView)
        
        checkImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        self.checkImageView.isHidden = true
    }
    
    func fill(color: UIColor) {
        self.backgroundColor = color
    }
}

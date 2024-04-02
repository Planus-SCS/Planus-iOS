//
//  CategorySelectCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

class CategorySelectCell: UITableViewCell {
    static let reuseIdentifier = "category-cell"
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.sizeToFit()
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = .planusBlack
        return label
    }()
    
    lazy var colorView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(colorView)
        self.backgroundColor = .planusBackgroundColor
    }
    
    func configureLayout() {
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        colorView.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(6)
            $0.width.height.equalTo(12)
        }
    }
    
    func fill(name: String, color: UIColor) {
        nameLabel.text = name
        colorView.backgroundColor = color
    }
}

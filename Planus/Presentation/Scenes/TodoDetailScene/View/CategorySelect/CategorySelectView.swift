//
//  CategorySelectView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

class CategorySelectView: UIView {
    
    var addNewItemButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "plusBtn"), for: .normal)
        button.setTitle("새 카테고리 추가", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.imageEdgeInsets = .init(top: 0, left: -5, bottom: 0, right: 5)
        button.tintColor = .planusBlack
        button.setTitleColor(.planusBlack, for: .normal)
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    var headerBarView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    var backButton: UIButton = {
        let image = UIImage(named: "pickerLeft") ?? UIImage()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        button.setImage(UIImage(named: "pickerLeft"), for: .normal)
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "카테고리 선택"
        label.font = UIFont(name: "Pretendard-Light", size: 16)
        label.sizeToFit()
        return label
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .planusBackgroundColor
        tableView.register(CategorySelectCell.self, forCellReuseIdentifier: CategorySelectCell.reuseIdentifier)
        tableView.separatorInset.left = 16
        tableView.separatorInset.right = 16
        return tableView
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
        self.backgroundColor = .planusBackgroundColor

        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        
        self.addSubview(headerBarView)
        headerBarView.addSubview(backButton)
        headerBarView.addSubview(titleLabel)
        self.addSubview(addNewItemButton)
        self.addSubview(tableView)
    }
    
    func configureLayout() {
        headerBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(84)
        }
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        addNewItemButton.snp.remakeConstraints {
            $0.top.equalTo(self.headerBarView.snp.bottom)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(130)
            $0.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(addNewItemButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

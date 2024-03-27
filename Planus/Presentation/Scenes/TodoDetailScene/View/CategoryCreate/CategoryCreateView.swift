//
//  CategoryCreateView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

class CategoryCreateView: UIView {
    
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
    
    var saveButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
        button.setTitleColor(UIColor(hex: 0x6495F4), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "카테고리 선택"
        label.font = UIFont(name: "Pretendard-Light", size: 16)
        label.sizeToFit()
        return label
    }()
    
    var nameField: UITextField = {
        let field = UITextField(frame: .zero)
        field.textAlignment = .center
        field.placeholder = "카테고리를 입력하세요"
        field.font = UIFont(name: "Pretendard-Medium", size: 18)
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        return field
    }()
    
    var separatorView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .gray
        return view
    }()
    
    var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "카테고리 색상을 선택택하세요"
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0.749, green: 0.78, blue: 0.843, alpha: 1)
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        cv.register(CategoryCreateCell.self, forCellWithReuseIdentifier: CategoryCreateCell.reuseIdentifier)
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
        return cv
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
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        
        self.addSubview(headerBarView)
        headerBarView.addSubview(backButton)
        headerBarView.addSubview(titleLabel)
        headerBarView.addSubview(saveButton)
        self.addSubview(nameField)
        self.addSubview(separatorView)
        self.addSubview(collectionView)
        self.addSubview(descLabel)
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
        
        saveButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        nameField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(264)
            $0.top.equalTo(headerBarView.snp.bottom).offset(30)
        }

        separatorView.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.leading.trailing.equalTo(nameField)
            $0.top.equalTo(nameField.snp.bottom).offset(10)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(separatorView).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(304)
            $0.height.equalTo(150)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(76),
            heightDimension: .absolute(36)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(66)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        group.contentInsets = .init(top: 15, leading: 0, bottom: 15, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
}

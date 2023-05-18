//
//  GroupCreateTagViewTest.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/19.
//

import UIKit

class GroupCreateTagViewTest: UIView {
    var testSource = ["그dddd룹1", "태ddddddd그2", "태ddd그3", "태그dd4", "태그4", "태그ddd4", "태그ddd4", ]
    
    var keyWordTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹과 관련된 키워드를 입력하세요"
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        return label
    }()
    
    var keyWordDescLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "박스 클릭 후 글자를 입력하세요"
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()
    
    lazy var tagCollectionView: UICollectionView = {
        let layout = EqualSpacedCollectionViewLayout()
        layout.estimatedItemSize = CGSize(width: 90, height: 40)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(GroupCreateTagCell.self, forCellWithReuseIdentifier: GroupCreateTagCell.reuseIdentifier)
        cv.backgroundColor = .brown
        cv.dataSource = self
        return cv
    }()
    
    lazy var tagCountValidateLabel: UILabel = self.validationLabelGenerator(text: "태그는 최대 5개까지 입력할 수 있어요")
    lazy var stringCountValidateLabel: UILabel = self.validationLabelGenerator(text: "한번에 최대 7자 이하만 적을 수 있어요")
    lazy var charcaterValidateLabel: UILabel = self.validationLabelGenerator(text: "띄어쓰기, 특수 문자는 빼주세요")
    lazy var duplicateValidateLabel: UILabel = self.validationLabelGenerator(text: "태그를 중복 없이 작성 해주세요")

    var tagCountCheckView: ValidationCheckImageView = .init()
    var stringCountCheckView: ValidationCheckImageView = .init()
    var charValidateCheckView: ValidationCheckImageView = .init()
    var duplicateValidateCheckView: ValidationCheckImageView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(keyWordTitleLabel)
        self.addSubview(keyWordDescLabel)
        self.addSubview(tagCollectionView)

        self.addSubview(tagCountValidateLabel)
        self.addSubview(tagCountCheckView)
        self.addSubview(stringCountValidateLabel)
        self.addSubview(stringCountCheckView)
        self.addSubview(charcaterValidateLabel)
        self.addSubview(charValidateCheckView)
        self.addSubview(duplicateValidateLabel)
        self.addSubview(duplicateValidateCheckView)
    }
    
    func configureLayout() {
        keyWordTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        keyWordDescLabel.snp.makeConstraints {
            $0.top.equalTo(keyWordTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(20)
        }
        
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(keyWordDescLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(100)
        }
        
        tagCountValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tagCountCheckView.snp.makeConstraints {
            $0.centerY.equalTo(tagCountValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        stringCountValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagCountValidateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        stringCountCheckView.snp.makeConstraints {
            $0.centerY.equalTo(stringCountValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        charcaterValidateLabel.snp.makeConstraints {
            $0.top.equalTo(stringCountValidateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        charValidateCheckView.snp.makeConstraints {
            $0.centerY.equalTo(charcaterValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        duplicateValidateLabel.snp.makeConstraints {
            $0.top.equalTo(charcaterValidateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().inset(30)
        }
        
        duplicateValidateCheckView.snp.makeConstraints {
            $0.centerY.equalTo(duplicateValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    func validationLabelGenerator(text: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = text
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }
}

extension GroupCreateTagViewTest: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.testSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupCreateTagCell.reuseIdentifier, for: indexPath) as? GroupCreateTagCell else {
            return UICollectionViewCell()
        }
        cell.fill(tag: testSource[indexPath.item])
        return cell
    }
    
    
}

class EqualSpacedCollectionViewLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        
        return attributes
    }
}



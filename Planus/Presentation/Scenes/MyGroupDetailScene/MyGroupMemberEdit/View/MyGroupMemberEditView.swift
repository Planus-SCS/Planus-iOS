//
//  MyGroupMemberEditView.swift
//  Planus
//
//  Created by Sangmin Lee on 3/26/24.
//

import UIKit
import RxSwift

final class MyGroupMemberEditView: UIView {
    lazy var memberCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createMemberSection())
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
        cv.register(MyGroupMemberEditCell.self, forCellWithReuseIdentifier: MyGroupMemberEditCell.reuseIdentifier)
        return cv
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .black
        return item
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MyGroupMemberEditView {
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.addSubview(memberCollectionView)
    }
    
    func configureLayout() {
        memberCollectionView.snp.makeConstraints {
            $0.edges.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

private extension MyGroupMemberEditView {
    func createMemberSection() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(66))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 26, bottom: 0, trailing: 26)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

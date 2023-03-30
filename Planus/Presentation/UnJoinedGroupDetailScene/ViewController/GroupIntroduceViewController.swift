//
//  GroupIntroduceViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

// 컴포지셔널 레이아웃 써서 어엄청 크게 만들자, 디퍼블을 쓸까? 고민되네

enum GroupIntroduceSectionKind: Int, CaseIterable {
    case info
    case notice
    case member
}

class GroupIntroduceViewController: UIViewController {
    static let headerElementKind = "group-introduce-view-controller-header-kind"
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        cv.register(
            GroupIntroduceInfoCell.self,
            forCellWithReuseIdentifier: GroupIntroduceInfoCell.reuseIdentifier
        )
        
        cv.register(
            GroupIntroduceNoticeCell.self,
            forCellWithReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier
        )
        
        cv.register(
            GroupIntroduceMemberCell.self,
            forCellWithReuseIdentifier: GroupIntroduceMemberCell.reuseIdentifier
        )
        cv.register(
            GroupIntroduceHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: Self.headerElementKind,
            withReuseIdentifier: GroupIntroduceHeaderSupplementaryView.reuseIdentifier
        )
        
        return cv
    }()
    
}

// MARK: Generate layout

extension GroupIntroduceViewController {
    private func createInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2),
                                               heightDimension: .fractionalWidth(1/2))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(45))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: Self.headerElementKind,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]
                
        return section
    }
    
    private func createNoticeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 2.5, leading: 0, bottom: 2.5, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)

        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(45))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: Self.headerElementKind,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }
    
    private func createMemberSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 2.5, leading: 0, bottom: 2.5, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)

        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(45))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: Self.headerElementKind,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self,
                  let sectionKind = GroupIntroduceSectionKind(rawValue: sectionIndex) else { return nil }
            
            // MARK: Item Layout
            switch sectionKind {
            case .info:
                return self.createInfoSection()
            case .notice:
                return self.createNoticeSection()
            case .member:
                return self.createMemberSection()
            }
        }
    }
}

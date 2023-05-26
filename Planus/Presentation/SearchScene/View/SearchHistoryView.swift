//
//  SearchHistoryView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/27.
//

import UIKit

enum SearchHistorySeactionKind: Int {
    case history = 0
}

class SearchHistoryView: UIView {
    static let headerElementKind = "search-history-view-header-kind"
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        cv.register(SearchHistoryCell.self, forCellWithReuseIdentifier: SearchHistoryCell.reuseIdentifier)
        cv.register(SearchHistoryHeaderView.self, forSupplementaryViewOfKind: Self.headerElementKind, withReuseIdentifier: SearchHistoryHeaderView.reuseIdentifier)
        return cv
    }()
}

extension SearchHistoryView {
    private func createHistorySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(66))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 26, bottom: 0, trailing: 26)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 85, trailing: 0)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(70))
        
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
            guard let sectionKind = SearchHistorySeactionKind(rawValue: sectionIndex) else { return nil }
            
            // MARK: Item Layout
            switch sectionKind {
            case .history:
                return self?.createHistorySection()
            }
        }
    }
}

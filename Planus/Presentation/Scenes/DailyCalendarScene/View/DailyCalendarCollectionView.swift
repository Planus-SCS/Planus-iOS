//
//  DailyCalendarCollectionView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit

class DailyCalendarCollectionView: UICollectionView {
    
    static let backgroundKind = "todo-background-element-kind"
    static let headerKind = "todo-header-element-kind"

    convenience init(frame: CGRect) {
        self.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        self.setCollectionViewLayout(self.createLayout(), animated: false)
        
        configureView()
    }
    
    private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        self.backgroundColor = .planusBackgroundColor
        
        self.register(DailyCalendarTodoCell.self, forCellWithReuseIdentifier: DailyCalendarTodoCell.reuseIdentifier)
        self.register(DailyCalendarEmptyTodoMockCell.self, forCellWithReuseIdentifier: DailyCalendarEmptyTodoMockCell.reuseIdentifier)
        self.register(DailyCalendarSectionHeaderSupplementaryView.self, forSupplementaryViewOfKind: Self.headerKind, withReuseIdentifier: DailyCalendarSectionHeaderSupplementaryView.reuseIdentifier)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(40)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(44)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 2, leading: 10, bottom: 2, trailing: 10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 12, bottom: 40, trailing: 12)
        
        let sectionBackground = NSCollectionLayoutDecorationItem.background(elementKind: Self.backgroundKind)
        sectionBackground.contentInsets = .init(top: 41, leading: 10, bottom: 30, trailing: 10)
        section.decorationItems = [sectionBackground]
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(52))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: Self.headerKind,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.register(DailyCalendarSectionBackgroundDecorationView.self, forDecorationViewOfKind: Self.backgroundKind)
        
        return layout
    }
}

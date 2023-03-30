//
//  GroupIntroduceViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

// 컴포지셔널 레이아웃 써서 어엄청 크게 만들자, 디퍼블을 쓸까? 고민되네

enum GroupIntroduceSectionKind: Int, CaseIterable {
    case info = 0
    case notice
    case member
}

class GroupIntroduceViewController: UIViewController {
    static let headerElementKind = "group-introduce-view-controller-header-kind"
    var headerSize: CGFloat = 330
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
//        cv.register(
//            GroupIntroduceInfoCell.self,
//            forCellWithReuseIdentifier: GroupIntroduceInfoCell.reuseIdentifier
//        )
        
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
        cv.register(GroupIntroduceInfoHeaderSupplementaryView.self, forSupplementaryViewOfKind: Self.headerElementKind, withReuseIdentifier: GroupIntroduceInfoHeaderSupplementaryView.reuseIdentifier)
        cv.dataSource = self
        return cv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

extension GroupIntroduceViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionKind = GroupIntroduceSectionKind(rawValue: section)
        switch sectionKind {
        case .info:
            return 0
        case .notice:
            return 0
        case .member:
            return 0
        case .none:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionKind = GroupIntroduceSectionKind(rawValue: indexPath.section)
        
        switch sectionKind {
        case .info:
            return UICollectionViewCell()
        case .notice:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier, for: indexPath) as? GroupIntroduceNoticeCell else { return UICollectionViewCell() }
            return cell
        case .member:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceMemberCell.reuseIdentifier, for: indexPath) as? GroupIntroduceMemberCell else { return UICollectionViewCell() }
            return cell
        case .none:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == Self.headerElementKind else { return UICollectionReusableView() }
        
        let sectionKind = GroupIntroduceSectionKind(rawValue: indexPath.section)
        
        switch sectionKind {
        case .info:
            guard kind == Self.headerElementKind,
                  let view = collectionView.dequeueReusableSupplementaryView(ofKind: Self.headerElementKind, withReuseIdentifier: GroupIntroduceInfoHeaderSupplementaryView.reuseIdentifier, for: indexPath) as? GroupIntroduceInfoHeaderSupplementaryView else { return UICollectionReusableView() }
            view.fill(title: "가보자네카라쿠베베", tag: "dfdfdfdfdkfjfjfjfjfjfjfjfjfjfjfjfj", memCount: "1/4", captin: "기정이짱짱")
            view.fill(image: UIImage(named: "groupTest1")!)
            return view
        case .notice:
            return UICollectionReusableView()
        case .member:
            return UICollectionReusableView()
        case .none:
            return UICollectionReusableView()
        }

    }
}

// MARK: Generate layout

extension GroupIntroduceViewController {
    private func createInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(headerSize))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(headerSize))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(330))

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
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 2.5, leading: 0, bottom: 2.5, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)

        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(45))
        
//        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: sectionHeaderSize,
//            elementKind: Self.headerElementKind,
//            alignment: .top
//        )
//
//        section.boundarySupplementaryItems = [sectionHeader]

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
        
//        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: sectionHeaderSize,
//            elementKind: Self.headerElementKind,
//            alignment: .top
//        )
//
//        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return StickyTopCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
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


class StickyTopCompositionalLayout: UICollectionViewCompositionalLayout {
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        let layoutAttributes = super.layoutAttributesForElements(in: rect)
//
//        layoutAttributes?.forEach({ (attributes) in
//            if attributes.indexPath.section == 0 && attributes.indexPath.item == 0 {
//                guard let collectionView = self.collectionView else { return }
//
//                let contentOffsetY = collectionView.contentOffset.y
//
//                if contentOffsetY > 0 {
//                    return
//                }
//
//                let width = collectionView.frame.width
//                let height = attributes.frame.height - contentOffsetY
//
//                attributes.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)
//            }
//
//        })
//
//        return layoutAttributes
//    }
    
    var headerSize: CGFloat = 330
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        guard let offset = collectionView?.contentOffset, let stLayoutAttributes = layoutAttributes else {
            return layoutAttributes
        }
        
        if offset.y < 0 {
            for attributes in stLayoutAttributes where attributes.representedElementKind == GroupIntroduceViewController.headerElementKind {
                let width = collectionView!.frame.width
                print(collectionView?.frame)
                let height = headerSize - offset.y
                attributes.frame = CGRect(x: 0, y: offset.y, width: width, height: height)
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

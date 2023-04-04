//
//  JoinedGroupNoticeDataSource.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit

class JoinedGroupNoticeDataSource: NSObject, UICollectionViewDataSource {
    weak var delegate: JoinedGroupNoticeDataSourceDelegate?
    static let headerElementKind = "joined-group-detail-view-controller-header-kind"
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionKind = JoinedGroupNoticeSectionKind(rawValue: section),
              let delegate else { return 0 }
        switch sectionKind {
        case .notice:
            return delegate.isNoticeFetched() ? 1 : 0
        case .member:
            return delegate.memberCount() ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionKind = JoinedGroupNoticeSectionKind(rawValue: indexPath.section),
              let delegate else { return UICollectionViewCell() }
        
        switch sectionKind {
        case .notice:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier, for: indexPath) as? GroupIntroduceNoticeCell else { return UICollectionViewCell() }
            cell.fill(notice: delegate.notice() ?? "")
            return cell
        case .member:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceMemberCell.reuseIdentifier, for: indexPath) as? GroupIntroduceMemberCell,
                  let item = delegate.memberInfo(index: indexPath.item) else { return UICollectionViewCell() }
            cell.fill(name: item.name, introduce: item.desc, isCaptin: item.isCap)
            cell.fill(image: UIImage(named: "DefaultProfileMedium")!)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: Self.headerElementKind, withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier, for: indexPath) as? GroupIntroduceDefaultHeaderView,
              let sectionKind = JoinedGroupNoticeSectionKind(rawValue: indexPath.section)
        else { return UICollectionReusableView() }
        
        view.fill(title: sectionKind.title, description: sectionKind.desc)
        return view
    }
}

protocol JoinedGroupNoticeDataSourceDelegate: NSObject {
    func memberCount() -> Int?
    func memberInfo(index: Int) -> Member?
    func notice() -> String?
    func isNoticeFetched() -> Bool
}

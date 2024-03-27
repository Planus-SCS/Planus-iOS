//
//  NotificationView.swift
//  Planus
//
//  Created by Sangmin Lee on 3/27/24.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationView: UIView {
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        return rc
    }()
    
    var emptyResultView: EmptyResultView = {
        let view = EmptyResultView(text: "그룹 신청이 없습니다.")
        view.isHidden = true
        return view
    }()
    
    lazy var resultCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(GroupJoinNotificationCell.self, forCellWithReuseIdentifier: GroupJoinNotificationCell.reuseIdentifier)
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .clear
        return collectionView
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

private extension NotificationView {
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.addSubview(emptyResultView)
        self.addSubview(resultCollectionView)
    }
    
    func configureLayout() {
        emptyResultView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        resultCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

private extension NotificationView {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(122))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)

        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

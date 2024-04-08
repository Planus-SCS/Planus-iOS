//
//  SearchHomeView.swift
//  Planus
//
//  Created by Sangmin Lee on 3/26/24.
//

import UIKit

final class SearchHomeView: UIView {
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        return rc
    }()
    
    lazy var resultCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createSection())
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.reuseIdentifier)
        collectionView.backgroundColor = .planusBackgroundColor
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    lazy var searchButton: UIBarButtonItem = {
        let image = UIImage(named: "searchBarIcon")?.withRenderingMode(.alwaysTemplate)
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .planusBlack
        return item
    }()
    
    var createGroupButton: SpringableButton = {
        let button = SpringableButton(frame: .zero)
        button.setImage(UIImage(named: "GroupAddBtn"), for: .normal)
        button.layer.cornerRadius = 25
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 2
        return button
    }()
    
    var navigationTitleView: UIImageView = {
        let image = UIImage(named: "PlanusGroup")
        let view = UIImageView(image: image)
        view.clipsToBounds = true
        return view
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


// MARK: configure UI
private extension SearchHomeView {
    func configureView() {
        self.backgroundColor = .planusBackgroundColor
        self.addSubview(resultCollectionView)
        self.addSubview(createGroupButton)
    }
    
    func configureLayout() {
        resultCollectionView.snp.makeConstraints {
            $0.edges.equalTo(self.safeAreaLayoutGuide)
        }
        
        createGroupButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(50)
        }
    }
}

// MARK: CollectionView Layout
private extension SearchHomeView {
    private func createSection() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(250))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 20, trailing: 7)
        
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

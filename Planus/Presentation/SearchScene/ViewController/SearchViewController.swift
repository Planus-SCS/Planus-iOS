//
//  SearchViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

struct GroupSearchResult {
    var title: String
    var imageName: String
    var tag: String?
    var memCount: String
    var captin: String
}

class SearchViewController: UIViewController {
    
    // 필요한거 화면에 뿌려줄 컬렉션 뷰, 근데 검색 결과를 보여줄 땐 한 뎁스를 타고 들어가야 한다!
    
    var testSource: [GroupSearchResult] = [
        GroupSearchResult(title: "네카라쿠베가보자",imageName: "groupTest1", tag: "#취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발 #취준 #공대 #코딩 #IT #개발", memCount: "1/2121212121212", captin: "이상민1ddfdfdfdfdfdfdf"),
        GroupSearchResult(title: "당토직야도가야지",imageName: "groupTest2", tag: "#취준 #공대 #코딩 #IT #개발", memCount: "3/4", captin: "이상민2"),
        GroupSearchResult(title: "안갈거야??",imageName: "groupTest3", tag: "#취준 #공대 #코딩 #IT #개발", memCount: "1/2", captin: "이상민3"),
        GroupSearchResult(title: "취업해야지?",imageName: "groupTest4", tag: "#취준 #공대 #코딩 #IT #개발", memCount: "3/4", captin: "이상민4")
    ]
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    lazy var resultCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createSection())
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    var headerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: 0xF5F5FB)
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 2
        return view
    }()
    
    var searchBarField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Medium", size: 12)
        
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        
        if let image = UIImage(named: "searchBarIcon") {
            textField.addleftimage(image: image, padding: 12)
        }
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "그룹명 또는 태그를 검색해보세요.",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x7A7A7A)]
        )

        return textField
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureLayout()
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(resultCollectionView)
        self.view.addSubview(headerView)
        headerView.addSubview(searchBarField)
    }
    
    func configureLayout() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        resultCollectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        searchBarField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(40)
        }
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        self.resultCollectionView.reloadData()
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        testSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as? SearchResultCell else { return UICollectionViewCell() }
        
        let item = testSource[indexPath.item]
        cell.fill(title: item.title, tag: item.tag, memCount: item.memCount, captin: item.captin)
        let image = UIImage(named: item.imageName) ?? UIImage()
        
        let width = (self.view.frame.width - 22)/2
        let height = width*1.3
        let resizedImage = UIImage.resizeImage(image: image, targetSize: CGSize(width: width, height: height))
        cell.fill(image: resizedImage)
        
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if (refreshControl.isRefreshing) {
                self.refreshControl.endRefreshing()
            }
    }
}

extension SearchViewController {
    private func createSection() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(250))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)
        
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

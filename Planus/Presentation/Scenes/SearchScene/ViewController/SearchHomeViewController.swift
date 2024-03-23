//
//  SearchHomeViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchHomeView: UIView {
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        return rc
    }()
    
    lazy var resultCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createSection())
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.reuseIdentifier)
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    lazy var searchButton: UIBarButtonItem = {
        let image = UIImage(named: "searchBarIcon")?.withRenderingMode(.alwaysTemplate)
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .black
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
        super.init(coder: coder)
        print("fatal error")
    }
}


// MARK: configure UI
private extension SearchHomeView {
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
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

final class SearchHomeViewController: UIViewController {
    
    var bag = DisposeBag()
    
    var viewModel: SearchHomeViewModel?
    var searchHomeView: SearchHomeView?
    
    var isInitLoading = true
    var isLoading: Bool = true
    var isEnded: Bool = false
    var tappedItemAt = PublishRelay<Int>()
    var refreshRequired = PublishRelay<Void>()
    var needLoadNextData = PublishRelay<Void>()
    
    convenience init(viewModel: SearchHomeViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        let view = SearchHomeView(frame: self.view.frame)
        self.view = view
        self.searchHomeView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureVC()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.titleView = searchHomeView?.navigationTitleView
        self.navigationItem.setRightBarButton(searchHomeView?.searchButton, animated: false)
    }
    
    func bind() {
        guard let viewModel,
              let searchHomeView else { return }
        
        let input = SearchHomeViewModel.Input(
            viewDidLoad: Observable.just(()),
            tappedItemAt: tappedItemAt.asObservable(),
            refreshRequired: refreshRequired.asObservable(),
            createBtnTapped: searchHomeView.createGroupButton.rx.tap.asObservable(),
            needLoadNextData: needLoadNextData.asObservable(),
            searchBtnTapped: searchHomeView.searchButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchAdditionalResult
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, range in
                let indexList = Array(range).map { IndexPath(item: $0, section: 0) }
                searchHomeView.resultCollectionView.performBatchUpdates({
                    searchHomeView.resultCollectionView.insertItems(at: indexList)
                }, completion: { _ in
                    vc.isLoading = false
                })
            })
            .disposed(by: bag)
        
        output
            .didFetchInitialResult
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.isInitLoading = false
                searchHomeView.resultCollectionView.performBatchUpdates({
                    searchHomeView.resultCollectionView.reloadSections(IndexSet(integer: 0))
                }, completion: { _ in
                    if searchHomeView.refreshControl.isRefreshing {
                        searchHomeView.refreshControl.endRefreshing()
                    }
                    vc.isLoading = false
                })
            })
            .disposed(by: bag)
        
        output
            .resultEnded
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.isEnded = true
            })
            .disposed(by: bag)
        
        output
            .didStartFetching
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.isInitLoading = true
                searchHomeView.resultCollectionView.reloadData()
            })
            .disposed(by: bag)
    }
    
    func configureVC() {
        searchHomeView?.resultCollectionView.dataSource = self
        searchHomeView?.resultCollectionView.delegate = self
        
        searchHomeView?.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
        
    @objc func refresh(_ sender: UIRefreshControl) {
        if !isLoading {
            sender.endRefreshing()
            isLoading = true
            isEnded = false
            refreshRequired.accept(())
        } else {
            sender.endRefreshing()
        }
    }
}

extension SearchHomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isInitLoading {
            return Int(UIScreen.main.bounds.height/250)*2
        }
        return viewModel?.result.count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as? SearchResultCell else { return UICollectionViewCell() }
        if isInitLoading {
            cell.startSkeletonAnimation()
            return cell
        }
        
        guard let item = viewModel?.result[indexPath.item] else { return UICollectionViewCell() }
        
        cell.stopSkeletonAnimation()
        cell.fill(
            title: item.name,
            tag: item.groupTags.map { "#\($0.name)" }.joined(separator: " "),
            memCount: "\(item.memberCount)/\(item.limitCount)",
            captin: item.leaderName
        )
        
        let cellBag = DisposeBag()
        cell.bag = cellBag
        
        viewModel?.fetchImage(key: item.groupImageUrl)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { data in
                cell.fill(image: UIImage(data: data))
            })
            .disposed(by: cellBag)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isLoading,
           !isEnded,
           scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height - 250 {
            isLoading = true
            needLoadNextData.accept(())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tappedItemAt.accept(indexPath.item)
    }
}

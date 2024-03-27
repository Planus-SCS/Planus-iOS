//
//  SearchHomeViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchHomeViewController: UIViewController {
    
    private let bag = DisposeBag()
    
    private var viewModel: SearchHomeViewModel?
    private var searchHomeView: SearchHomeView?
    
    private var isInitLoading = true
    private var isLoading: Bool = true
    private var isEnded: Bool = false
    
    private let tappedItemAt = PublishRelay<Int>()
    private let refreshRequired = PublishRelay<Void>()
    private let needLoadNextData = PublishRelay<Void>()
    
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
}

// MARK: - bind viewModel
extension SearchHomeViewController {
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
}

// MARK: - configure VC
private extension SearchHomeViewController {
    func configureVC() {
        searchHomeView?.resultCollectionView.dataSource = self
        searchHomeView?.resultCollectionView.delegate = self
        
        searchHomeView?.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
}

// MARK: - Actions
private extension SearchHomeViewController {
    @objc 
    func refresh(_ sender: UIRefreshControl) {
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

// MARK: - Collection View
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
        guard let viewModel,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as? SearchResultCell else { return UICollectionViewCell() }
        if isInitLoading {
            cell.startSkeletonAnimation()
            return cell
        }
        
        let item = viewModel.result[indexPath.item]
        
        cell.stopSkeletonAnimation()
        cell.fill(
            title: item.name,
            tag: item.groupTags.map { "#\($0.name)" }.joined(separator: " "),
            memCount: "\(item.memberCount)/\(item.limitCount)",
            captin: item.leaderName,
            imgFetcher: viewModel.fetchImage(key: item.groupImageUrl)
        )
        
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

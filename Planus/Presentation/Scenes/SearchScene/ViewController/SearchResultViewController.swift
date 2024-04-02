//
//  SearchResultViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/27.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchResultViewController: UIViewController {
    
    private var bag = DisposeBag()
    
    private var viewModel: SearchResultViewModel?
    private var searchResultView: SearchResultView?
    
    private var searchResultCollectionDataSource: SearchResultCollectionDataSource?
    private var searchHistoryCollectionDataSource: SearchHistoryCollectionDataSource?
    
    private var isLoading: Bool = true
    private var isEnded: Bool = false
    
    private var tappedItemAt = PublishRelay<Int>()
    private var refreshRequired = PublishRelay<Void>()
    private var searchBtnTapped = PublishRelay<Void>()
    private var needLoadNextData = PublishRelay<Void>()
    private var tappedHistoryAt = PublishRelay<Int>()
    private var needFetchHistory = PublishRelay<Void>()
    private var removeAllHistory = PublishRelay<Void>()
    
    convenience init(viewModel: SearchResultViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        let view = SearchResultView(frame: self.view.frame)
        self.view = view
        self.searchResultView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        bind()
        
        searchResultView?.searchBarField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let searchResultView else { return }
        
        self.navigationItem.setLeftBarButton(searchResultView.backButton, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: searchResultView.searchBarField), animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - bind viewModel
private extension SearchResultViewController {
    func bind() {
        guard let viewModel,
              let searchResultView else { return }
        
        searchResultView.historyView.collectionView.rx
            .itemSelected
            .subscribe(onNext: { _ in
                searchResultView.searchBarField.resignFirstResponder()
            })
            .disposed(by: bag)
        
        let input = SearchResultViewModel.Input(
            viewDidLoad: Observable.just(()),
            tappedItemAt: searchResultView.resultCollectionView.rx.itemSelected.map { $0.item }.asObservable(),
            tappedHistoryAt: searchResultView.historyView.collectionView.rx.itemSelected.map { $0.item }.asObservable(),
            refreshRequired: refreshRequired.asObservable(),
            keywordChanged: searchResultView.searchBarField.rx.text.asObservable(),
            searchBtnTapped: searchBtnTapped.asObservable(),
            createBtnTapped: searchResultView.createGroupButton.rx.tap.asObservable(),
            needLoadNextData: needLoadNextData.asObservable(),
            needFetchHistory: needFetchHistory.asObservable(),
            removeAllHistory: removeAllHistory.asObservable(),
            backBtnTapped: searchResultView.backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchAdditionalResult
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, range in
                let indexList = Array(range).map { IndexPath(item: $0, section: 0) }
                searchResultView.resultCollectionView.performBatchUpdates({
                    searchResultView.resultCollectionView.insertItems(at: indexList)
                }, completion: { _ in
                    vc.isLoading = false
                })
            })
            .disposed(by: bag)
        
        output
            .didStartFetching
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                searchResultView.historyView.isHidden = true
                vc.needFetchHistory.accept(())
                searchResultView.resultCollectionView.isHidden = false
                searchResultView.resultCollectionView.reloadData()
            })
            .disposed(by: bag)
        
        output
            .didFetchInitialResult
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                searchResultView.resultCollectionView.performBatchUpdates({
                    searchResultView.resultCollectionView.reloadSections(IndexSet(integer: 0))
                }, completion: { _ in
                    if searchResultView.refreshControl.isRefreshing {
                        searchResultView.refreshControl.endRefreshing()
                    }
                    vc.isLoading = false
                    searchResultView.emptyResultView.setAnimatedIsHidden(viewModel.result.count != 0)
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
            .keywordChanged
            .distinctUntilChanged()
            .bind(to: searchResultView.searchBarField.rx.text)
            .disposed(by: bag)
        
        output
            .didFetchHistory
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                searchResultView.historyView.collectionView.reloadSections(IndexSet(integer: 0))
            })
            .disposed(by: bag)
    }
}

// MARK: Actions
private extension SearchResultViewController {
    @objc func keyboardEvent(notification: Notification) {
        if notification.name == UIResponder.keyboardWillShowNotification { // 히스토리 받아오기
            if let searchResultView,
               searchResultView.historyView.isHidden {
                searchResultView.historyView.setAnimatedIsHidden(false, duration: 0.1, onCompletion: { [weak self] in
                    searchResultView.resultCollectionView.isHidden = true
                    searchResultView.emptyResultView.isHidden = true
                })
            }
        }
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        if !isLoading {
            sender.endRefreshing()
            
            isEnded = false
            isLoading = true
            refreshRequired.accept(())
        } else {
            sender.endRefreshing()
        }
    }
    
    func searchBtnTapAction() {
        searchBtnTapped.accept(())
        searchResultView?.searchBarField.resignFirstResponder()
    }
}

// MARK: configure
private extension SearchResultViewController {
    func configureVC() {
        guard let viewModel else { return }
        
        searchResultView?.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        searchResultView?.resultCollectionView.delegate = self
        searchResultView?.historyView.collectionView.delegate = self
        
        let resultDataSource = SearchResultCollectionDataSource(viewModel: viewModel)
        let historyDataSource = SearchHistoryCollectionDataSource(viewModel: viewModel)
        
        self.searchResultCollectionDataSource = resultDataSource
        self.searchHistoryCollectionDataSource = historyDataSource
        
        searchResultView?.resultCollectionView.dataSource = resultDataSource
        searchResultView?.historyView.collectionView.dataSource = historyDataSource
        
        searchResultView?.searchBarField.delegate = self
    }
}

extension SearchResultViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBtnTapAction()
        return true
    }
}

final class SearchResultCollectionDataSource: NSObject, UICollectionViewDataSource {
    var viewModel: SearchResultViewModel?
    
    convenience init(viewModel: SearchResultViewModel? = nil) {
        self.init()
        self.viewModel = viewModel
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewModel,
           viewModel.isInitLoading {
            return Int(UIScreen.main.bounds.height/250)*2
        }
            return viewModel?.result.count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as? SearchResultCell else { return UICollectionViewCell() }
        if viewModel.isInitLoading {
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
}

final class SearchHistoryCollectionDataSource: NSObject, UICollectionViewDataSource {
    var viewModel: SearchResultViewModel?
    
    convenience init(viewModel: SearchResultViewModel? = nil) {
        self.init()
        self.viewModel = viewModel
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return viewModel?.history.count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchHistoryCell.reuseIdentifier, for: indexPath) as? SearchHistoryCell,
                  let item = viewModel?.history[indexPath.item] else { return UICollectionViewCell() }
            cell.fill(keyWord: item)
            
            cell.removeClosure = { [weak self] in
                self?.viewModel?.removeHistoryAt(item: indexPath.item)
            }
            return cell
    }
}

extension SearchResultViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let searchResultView else { return }
        if scrollView == searchResultView.resultCollectionView,
           !isLoading,
           !isEnded,
           scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height - 250 {
            isLoading = true
            needLoadNextData.accept(())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let searchResultView else { return UICollectionReusableView() }
        
        switch collectionView {
        case searchResultView.historyView.collectionView:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchHistoryHeaderView.reuseIdentifier, for: indexPath) as? SearchHistoryHeaderView else { return UICollectionReusableView() }
            view.closure = { [weak self] in
                self?.removeAllHistory.accept(())
            }
            return view
        default:
            return UICollectionReusableView()
        }
    }
}

extension SearchResultViewController: UIGestureRecognizerDelegate {}

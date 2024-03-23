//
//  SearchResultViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/27.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchResultView: UIView {
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        return rc
    }()
    
    lazy var historyView: SearchHistoryView = {
        let historyView = SearchHistoryView(frame: .zero)
        historyView.isHidden = true
        historyView.alpha = 0
        return historyView
    }()
    
    var emptyResultView: EmptyResultView = {
        let view = EmptyResultView(text: "검색 결과가 존재하지 않습니다.")
        view.isHidden = true
        return view
    }()
    
    lazy var resultCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createSection())
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.reuseIdentifier)
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
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .black
        return item
    }()
    
    lazy var searchBarField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 70, height: 40))
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Medium", size: 12)
        
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.clearButtonMode = .whileEditing
        if let image = UIImage(named: "searchBarIcon") {
            textField.addleftimage(image: image, padding: 12)
        }
        textField.enablesReturnKeyAutomatically = true
        textField.returnKeyType = .search
        textField.attributedPlaceholder = NSAttributedString(
            string: "그룹명 또는 태그를 검색해보세요.",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x7A7A7A)]
        )

        return textField
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

// MARK: Configure UI
private extension SearchResultView {
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.addSubview(resultCollectionView)
        self.addSubview(emptyResultView)
        self.addSubview(historyView)
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
        
        historyView.snp.makeConstraints {
            $0.edges.equalTo(self.safeAreaLayoutGuide)
        }
        
        emptyResultView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: CollectionView Layout
private extension SearchResultView {
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

final class SearchResultViewController: UIViewController {
    
    // 필요한거 화면에 뿌려줄 컬렉션 뷰, 근데 검색 결과를 보여줄 땐 한 뎁스를 타고 들어가야 한다!
    var bag = DisposeBag()
    
    var viewModel: SearchResultViewModel?
    var searchResultView: SearchResultView?
    
    var searchResultCollectionDataSource: SearchResultCollectionDataSource?
    var searchHistoryCollectionDataSource: SearchHistoryCollectionDataSource?
    
    var isLoading: Bool = true
    var isEnded: Bool = false
    
    var tappedItemAt = PublishRelay<Int>()
    var refreshRequired = PublishRelay<Void>()
    var searchBtnTapped = PublishRelay<Void>()
    var needLoadNextData = PublishRelay<Void>()
    var tappedHistoryAt = PublishRelay<Int>()
    var needFetchHistory = PublishRelay<Void>()
    var removeAllHistory = PublishRelay<Void>()
    
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
        
        configureView()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
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
        if notification.name == UIResponder.keyboardWillShowNotification { // 여기서 히스토리 받아오기
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
    func configureView() {
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
                captin: item.leaderName
            )
            
            let cellBag = DisposeBag()
            cell.bag = cellBag
            viewModel.fetchImage(key: item.groupImageUrl)
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onSuccess: { data in
                    cell.fill(image: UIImage(data: data))
                })
                .disposed(by: cellBag)
            
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

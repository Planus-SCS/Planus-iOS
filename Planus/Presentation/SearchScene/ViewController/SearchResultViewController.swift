//
//  SearchResultViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/27.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultViewController: UIViewController {
    
    // 필요한거 화면에 뿌려줄 컬렉션 뷰, 근데 검색 결과를 보여줄 땐 한 뎁스를 타고 들어가야 한다!
    var bag = DisposeBag()
    
    var viewModel: SearchResultViewModel?
    
    var isLoading: Bool = true
    var isEnded: Bool = false
    var tappedItemAt = PublishSubject<Int>()
    var refreshRequired = PublishSubject<Void>()
    var searchBtnTapped = PublishSubject<Void>()
    var needLoadNextData = PublishSubject<Void>()
    var tappedHistoryAt = PublishSubject<Int>()
    var needFetchHistory = PublishSubject<Void>()
    var removeHistoryAt = PublishSubject<Int>()
    var removeAllHistory = PublishSubject<Void>()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    lazy var historyView: SearchHistoryView = {
        let historyView = SearchHistoryView(frame: .zero)
        historyView.collectionView.dataSource = self
        historyView.collectionView.delegate = self
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
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    @objc func backBtnAction() {
        navigationController?.popViewController(animated: true)
    }
    
    lazy var searchBarField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 55, height: 40))
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Medium", size: 12)
        
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
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
    
    convenience init(viewModel: SearchResultViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
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
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setLeftBarButton(backButton, animated: true)
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: searchBarField), animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        searchBarField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardEvent(notification: Notification) {
        if notification.name == UIResponder.keyboardWillShowNotification { // 여기서 히스토리 받아오기
            if historyView.isHidden {
                historyView.setAnimatedIsHidden(false, duration: 0.1, onCompletion: { [weak self] in
                    self?.resultCollectionView.isHidden = true
                    self?.emptyResultView.isHidden = true
                    print("key")
                })
            }
        }
    }
    
    func bind() {
        guard let viewModel else { return }

        let input = SearchResultViewModel.Input(
            viewDidLoad: Observable.just(()),
            tappedItemAt: tappedItemAt.asObservable(),
            tappedHistoryAt: tappedHistoryAt.asObservable(),
            refreshRequired: refreshRequired.asObservable(),
            keywordChanged: searchBarField.rx.text.asObservable(),
            searchBtnTapped: searchBtnTapped.asObservable(),
            createBtnTapped: createGroupButton.rx.tap.asObservable(),
            needLoadNextData: needLoadNextData.asObservable(),
            needFetchHistory: needFetchHistory.asObservable(),
            removeHistoryAt: removeHistoryAt.asObservable(),
            removeAllHistory: removeAllHistory.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchAdditionalResult
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, range in
                let indexList = Array(range).map { IndexPath(item: $0, section: 0) }
                vc.resultCollectionView.performBatchUpdates({
                    vc.resultCollectionView.insertItems(at: indexList)
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
                vc.historyView.isHidden = true
                vc.spinner.startAnimating()
                vc.needFetchHistory.onNext(())
            })
            .disposed(by: bag)
        
        output
            .didFetchInitialResult
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                print("reload!")
                vc.resultCollectionView.performBatchUpdates({
                    vc.resultCollectionView.reloadSections(IndexSet(integer: 0))
                }, completion: { _ in
                    if vc.refreshControl.isRefreshing {
                        vc.refreshControl.endRefreshing()
                    }
                    vc.isLoading = false
                    print(viewModel.result.count == 0)
                    vc.resultCollectionView.setAnimatedIsHidden(viewModel.result.count == 0)
                    vc.emptyResultView.setAnimatedIsHidden(viewModel.result.count != 0)
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
            .bind(to: searchBarField.rx.text)
            .disposed(by: bag)
        
        output
            .didFetchHistory
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.historyView.collectionView.reloadSections(IndexSet(integer: 0))
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(resultCollectionView)
        self.view.addSubview(emptyResultView)
        self.view.addSubview(spinner)
        self.view.addSubview(historyView)
        self.view.addSubview(createGroupButton)
    }
    
    func configureLayout() {
        resultCollectionView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        createGroupButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(50)
        }
        
        historyView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        spinner.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(50)
        }
        
        emptyResultView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        refreshRequired.onNext(())
        isEnded = false
        isLoading = true
    }
    
    func searchBtnTapAction() {
        searchBtnTapped.onNext(())
        searchBarField.resignFirstResponder()
    }
}

extension SearchResultViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBtnTapAction()
        return true
    }
}

extension SearchResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case self.resultCollectionView:
            return 1
        case historyView.collectionView:
            return 1
        default:
            return Int()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case self.resultCollectionView:
            return viewModel?.result.count ?? Int()
        case historyView.collectionView:
            return viewModel?.history.count ?? Int()
        default:
            return Int()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.resultCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as? SearchResultCell,
                  let item = viewModel?.result[indexPath.item] else { return UICollectionViewCell() }
            
            cell.fill(
                title: item.name,
                tag: item.groupTags.map { "#\($0.name)" }.joined(separator: " "),
                memCount: "\(item.memberCount)/\(item.limitCount)",
                captin: item.leaderName
            )
            
            viewModel?.fetchImage(key: item.groupImageUrl)
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onSuccess: { data in
                    cell.fill(image: UIImage(data: data))
                })
                .disposed(by: bag)
            
            return cell
        case historyView.collectionView: // 삭제버튼 핸들러도 같이 넘기자
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchHistoryCell.reuseIdentifier, for: indexPath) as? SearchHistoryCell,
                  let item = viewModel?.history[indexPath.item] else { return UICollectionViewCell() }
            cell.fill(keyWord: item)
            
            cell.closure = { [weak self] in
                self?.removeHistoryAt.onNext(indexPath.item)
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.resultCollectionView,
           !isLoading,
           !isEnded,
           scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            isLoading = true
            needLoadNextData.onNext(())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.resultCollectionView:
            tappedItemAt.onNext(indexPath.item)
        case historyView.collectionView:
            searchBarField.resignFirstResponder()
            tappedHistoryAt.onNext(indexPath.item)
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch collectionView {
        case historyView.collectionView:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchHistoryHeaderView.reuseIdentifier, for: indexPath) as? SearchHistoryHeaderView else { return UICollectionReusableView() }
            view.closure = { [weak self] in
                self?.removeAllHistory.onNext(())
            }
            return view
        default:
            return UICollectionReusableView()
        }
    }
}

extension SearchResultViewController {
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

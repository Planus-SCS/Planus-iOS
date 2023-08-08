//
//  SearchHomeViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift
import RxCocoa

class SearchHomeViewController: UIViewController {
    
    // 필요한거 화면에 뿌려줄 컬렉션 뷰, 근데 검색 결과를 보여줄 땐 한 뎁스를 타고 들어가야 한다!
    var bag = DisposeBag()
    
    var viewModel: SearchHomeViewModel?
    
    var isLoading: Bool = true
    var isEnded: Bool = false
    var tappedItemAt = PublishSubject<Int>()
    var refreshRequired = PublishSubject<Void>()
    var needLoadNextData = PublishSubject<Void>()
    
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
    
    lazy var searchButton: UIBarButtonItem = {
        let image = UIImage(named: "searchBarIcon")?.withRenderingMode(.alwaysTemplate)
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(searchBtnTapped))
        item.tintColor = .black
        return item
    }()
    
//    var headerView: UIView = {
//        let view = UIView(frame: .zero)
//        view.backgroundColor = UIColor(hex: 0xF5F5FB)
//        view.layer.masksToBounds = false
//        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
//        view.layer.shadowOpacity = 1
//        view.layer.shadowOffset = CGSize(width: 0, height: 1)
//        view.layer.shadowRadius = 2
//        return view
//    }()
//
//    lazy var searchBarField: UITextField = {
//        let textField = UITextField(frame: .zero)
//        textField.textColor = .black
//        textField.font = UIFont(name: "Pretendard-Medium", size: 12)
//
//        textField.backgroundColor = .white
//        textField.layer.cornerRadius = 10
//        textField.clipsToBounds = true
//        textField.clearButtonMode = .whileEditing
//        textField.delegate = self
//        if let image = UIImage(named: "searchBarIcon") {
//            textField.addleftimage(image: image, padding: 12)
//        }
//
//        textField.attributedPlaceholder = NSAttributedString(
//            string: "그룹명 또는 태그를 검색해보세요.",
//            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x7A7A7A)]
//        )
//
//        return textField
//    }()
    
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
    
    convenience init(viewModel: SearchHomeViewModel) {
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
        
        self.navigationItem.titleView = navigationTitleView
        self.navigationItem.setRightBarButton(searchButton, animated: false)
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = SearchHomeViewModel.Input(
            viewDidLoad: Observable.just(()),
            tappedItemAt: tappedItemAt.asObservable(),
            refreshRequired: refreshRequired.asObservable(),
            createBtnTapped: createGroupButton.rx.tap.asObservable(),
            needLoadNextData: needLoadNextData.asObservable(),
            searchBtnTapped: searchButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchAdditionalResult
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, range in
                let indexList = Array(range).map { IndexPath(item: $0, section: 0) }
                vc.resultCollectionView.performBatchUpdates({
                    print("addition")
                    vc.resultCollectionView.insertItems(at: indexList)
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
                vc.resultCollectionView.performBatchUpdates({
                    print("init")
                    vc.resultCollectionView.reloadSections(IndexSet(integer: 0))
                }, completion: { _ in
                    if vc.refreshControl.isRefreshing {
                        vc.refreshControl.endRefreshing()
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
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(resultCollectionView)
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
    }
    
    @objc func searchBtnTapped(_ sender: UIBarButtonItem) {}
    
    @objc func refresh(_ sender: UIRefreshControl) {
        if !isLoading {
            isLoading = true
            isEnded = false
            refreshRequired.onNext(())
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
        viewModel?.result.count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as? SearchResultCell,
              let item = viewModel?.result[indexPath.item] else { return UICollectionViewCell() }
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
            needLoadNextData.onNext(())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tappedItemAt.onNext(indexPath.item)
    }
}

extension SearchHomeViewController {
    private func createSection() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(250))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 20, trailing: 7)
        
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

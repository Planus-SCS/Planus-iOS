//
//  NotificationViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/31.
//

import UIKit
import RxSwift
import RxCocoa

struct GroupJoinRequest {
    var imageURL: String
    var group: String
    var name: String
    var desc: String
}

class NotificationViewController: UIViewController {
    
    var viewModel: NotificationViewModel?
    
    // 필요한거 화면에 뿌려줄 컬렉션 뷰, 근데 검색 결과를 보여줄 땐 한 뎁스를 타고 들어가야 한다!
    var bag = DisposeBag()
    
//    var viewModel: SearchViewModel?
    
    var tappedItemAt = PublishSubject<Int>()
    var refreshRequired = PublishSubject<Void>()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    lazy var resultCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(GroupJoinNotificationCell.self, forCellWithReuseIdentifier: GroupJoinNotificationCell.reuseIdentifier)
        collectionView.dataSource = self
//        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    convenience init(viewModel: SearchViewModel) {
        self.init(nibName: nil, bundle: nil)
//        self.viewModel = viewModel
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
        navigationItem.title = "그룹 신청 관리"

        navigationItem.setLeftBarButton(backButton, animated: false)
//        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    @objc func backBtnAction() {
        self.navigationController?.popViewController(animated: true)
    }
//    func bind() {
//        guard let viewModel else { return }
//
//        let input = SearchViewModel.Input(
//            viewDidLoad: Observable.just(()),
//            tappedItemAt: tappedItemAt.asObservable(),
//            refreshRequired: refreshRequired.asObservable(),
//            keywordChanged: searchBarField.rx.text.asObservable(),
//            searchBtnTapped: searchBtnTapped.asObservable(),
//            createBtnTapped: createGroupButton.rx.tap.asObservable()
//        )
//
//        let output = viewModel.transform(input: input)
//
//        output
//            .didFinishFetchResult
//            .compactMap { $0 }
//            .withUnretained(self)
//            .subscribe(onNext: { vc, _ in
//                vc.resultCollectionView.reloadData()
//            })
//            .disposed(by: bag)
//
//        output
//            .fetchResultProcessing
//            .compactMap { $0 }
//            .withUnretained(self)
//            .subscribe(onNext: { vc, _ in
//                /*
//                 로딩 인디케이터 or 스켈레톤뷰
//                 */
//            })
//            .disposed(by: bag)
//
//        output
//            .didAddResult
//            .withUnretained(self)
//            .subscribe(onNext: { count in
//                /*
//                 insert
//                 */
//            })
//            .disposed(by: bag)
//    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(resultCollectionView)
    }
    
    func configureLayout() {
        resultCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        self.resultCollectionView.reloadData()
    }
}
//
//
extension NotificationViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        source.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupJoinNotificationCell.reuseIdentifier, for: indexPath) as? GroupJoinNotificationCell else { return UICollectionViewCell() }

        let item = source[indexPath.item]
        cell.fill(image: item.imageURL, title: item.group, name: item.name, desc: item.desc)
        return cell
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (refreshControl.isRefreshing) {
            self.refreshControl.endRefreshing()
            refreshRequired.onNext(())
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tappedItemAt.onNext(indexPath.item)
    }
}

extension NotificationViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(122))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)

        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

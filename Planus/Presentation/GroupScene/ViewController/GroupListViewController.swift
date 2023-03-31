//
//  GroupListViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/31.
//

import UIKit
import RxSwift

struct JoinedGroupViewModel {
    var id: String
    var title: String
    var imageName: String
    var tag: String?
    var memCount: String
    var captin: String
    var onlineCount: String
}

class GroupListViewController: UIViewController {
    
    var source: [JoinedGroupViewModel] = [
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest1", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4"),
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest2", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4"),
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest3", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4"),
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest4", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4"),
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest2", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4"),
        JoinedGroupViewModel(id: "1", title: "가보자네카라쿠베베", imageName: "groupTest1", tag: "#태그개수 #4개까지 #제한하는거 #어때 #5개까지", memCount: "4/18", captin: "기정이짱짱", onlineCount: "4")
    ]
    
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
        collectionView.register(JoinedGroupCell.self, forCellWithReuseIdentifier: JoinedGroupCell.reuseIdentifier)
        collectionView.dataSource = self
//        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        collectionView.refreshControl = refreshControl
        return collectionView
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
        
//        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.title = "그룹 신청 관리"
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
extension GroupListViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        source.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JoinedGroupCell.reuseIdentifier, for: indexPath) as? JoinedGroupCell else { return UICollectionViewCell() }

        let item = source[indexPath.item]
        cell.fill(title: item.title, tag: item.tag, memCount: item.memCount, captin: item.captin, onlineCount: item.onlineCount, image: item.imageName)
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

extension GroupListViewController {
    private func createLayout() -> UICollectionViewLayout {
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

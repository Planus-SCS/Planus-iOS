//
//  GroupListViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/31.
//

import UIKit
import RxSwift

class GroupListViewController: UIViewController {
    
    static let headerElementKind = "group-list-view-controller-header-kind"
    
    var viewModel: GroupListViewModel?

    var bag = DisposeBag()
        
    var tappedItemAt = PublishSubject<Int>()
    var becameOnlineStateAt = PublishSubject<Int>()
    var becameOfflineStateAt = PublishSubject<Int>()

    var refreshRequired = PublishSubject<Void>()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    lazy var resultCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(JoinedGroupCell.self, forCellWithReuseIdentifier: JoinedGroupCell.reuseIdentifier)
        collectionView.register(JoinedGroupSectionHeaderView.self, forSupplementaryViewOfKind: Self.headerElementKind, withReuseIdentifier: JoinedGroupSectionHeaderView.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    var emptyResultView: EmptyResultView = {
        let view = EmptyResultView(text: "그룹 신청이 없습니다.")
        view.isHidden = true
        return view
    }()
    
    lazy var notificationButton: UIBarButtonItem = {
        let image = UIImage(named: "notificationIcon")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(notificationBtnAction))
        item.tintColor = .black
        return item
    }()
    
    @objc func notificationBtnAction() {
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let imageRepo = DefaultImageRepository(apiProvider: api)
        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let setTokenUseCase = DefaultSetTokenUseCase(tokenRepository: tokenRepo)
        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
        let fetchJoinApplyUseCase = DefaultFetchJoinApplyListUseCase(myGroupRepository: myGroupRepo)
        let acceptGroupJoinUseCase = DefaultAcceptGroupJoinUseCase(myGroupRepository: myGroupRepo)
        let denyGroupJoinUseCase = DefaultDenyGroupJoinUseCase(myGroupRepository: myGroupRepo)
        let vm = NotificationViewModel(getTokenUseCase: getTokenUseCase, refreshTokenUseCase: refreshTokenUseCase, setTokenUseCase: setTokenUseCase, fetchJoinApplyListUseCase: fetchJoinApplyUseCase, fetchImageUseCase: fetchImageUseCase, acceptGroupJoinUseCase: acceptGroupJoinUseCase, denyGroupJoinUseCase: denyGroupJoinUseCase)
        let vc = NotificationViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    convenience init(viewModel: GroupListViewModel) {
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
        navigationItem.title = "내가 참여중인 그룹"
        navigationItem.setRightBarButton(notificationButton, animated: true)
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = GroupListViewModel.Input(
            viewDidLoad: Observable.just(()),
            tappedAt: tappedItemAt.asObservable(),
            becameOnlineStateAt: becameOnlineStateAt.asObservable(),
            becameOfflineStateAt: becameOfflineStateAt.asObservable(),
            refreshRequired: refreshRequired.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchJoinedGroup
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.resultCollectionView.reloadData()
                vc.emptyResultView.isHidden = (viewModel.groupList?.count == 0) ? true : false
            })
            .disposed(by: bag)
        
        output
            .didChangeOnlineStateAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                print(index)
            })
            .disposed(by: bag)
        
        output
            .needReloadItemAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                
                vc.resultCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            })
            .disposed(by: bag)
    }
    
    
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
        refreshRequired.onNext(())
    }
}

extension GroupListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.groupList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JoinedGroupCell.reuseIdentifier, for: indexPath) as? JoinedGroupCell,
              let item = viewModel?.groupList?[indexPath.item] else { return UICollectionViewCell() }

        let cellBag = DisposeBag()
        cell.indexPath = indexPath
        cell.bag = cellBag
        cell.onlineSwitch.rx.isOn
            .withUnretained(self)
            .subscribe(onNext: { vc, isOn in
                // 네트워크 요청 성공 시 스위치 토글을 옮겨야한다..!
                // 아니면 요청후 성공하면 유지, 실패하면 다시 원래자리로 돌리는거..?
                if isOn {
                    vc.becameOnlineStateAt.onNext(indexPath.item)
                } else {
                    vc.becameOfflineStateAt.onNext(indexPath.item)
                }
            })
            .disposed(by: cellBag)
        
        cell.fill(
            title: item.groupName,
            tag: item.groupTags.map { "#\($0.name)" }.joined(separator: " "),
            memCount: "\(item.totalCount)/\(item.limitCount)",
            leaderName: item.leaderName,
            onlineCount: "\(item.onlineCount)"
        )
        
        viewModel?.fetchImage(key: item.groupImageUrl)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { data in
                cell.fill(image: UIImage(data: data))
            })
            .disposed(by: bag)
        
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: JoinedGroupSectionHeaderView.reuseIdentifier, for: indexPath) as? JoinedGroupSectionHeaderView else { return UICollectionReusableView() }
        view.fill(title: "그룹 이미지 상단의 슬라이드를 움직여 스터디를 시작하세요")
        return view
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
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 14, trailing: 0)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: -7, trailing: 7)
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(34))

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: Self.headerElementKind,
            alignment: .top
        )

        section.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

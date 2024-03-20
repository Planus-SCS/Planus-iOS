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
        
    var isInitLoading = false
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
        let view = EmptyResultView(text: "가입된 그룹이 없습니다.")
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
        //FIXME: NotificationCoordinator 호출하는 액션 추가
//        let api = NetworkManager()
//        let keyChain = KeyChainManager()
//        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyValueStorage: keyChain)
//        let imageRepo = DefaultImageRepository(apiProvider: api)
//        let myGroupRepo = DefaultMyGroupRepository(apiProvider: api)
//        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
//        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
//        let setTokenUseCase = DefaultSetTokenUseCase(tokenRepository: tokenRepo)
//        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
//        let fetchJoinApplyUseCase = DefaultFetchJoinApplyListUseCase(myGroupRepository: myGroupRepo)
//        let acceptGroupJoinUseCase = DefaultAcceptGroupJoinUseCase(myGroupRepository: myGroupRepo)
//        let denyGroupJoinUseCase = DefaultDenyGroupJoinUseCase(myGroupRepository: myGroupRepo)
//        let vm = NotificationViewModel(getTokenUseCase: getTokenUseCase, refreshTokenUseCase: refreshTokenUseCase, setTokenUseCase: setTokenUseCase, fetchJoinApplyListUseCase: fetchJoinApplyUseCase, fetchImageUseCase: fetchImageUseCase, acceptGroupJoinUseCase: acceptGroupJoinUseCase, denyGroupJoinUseCase: denyGroupJoinUseCase)
//        let vc = NotificationViewController(viewModel: vm)
//        navigationController?.pushViewController(vc, animated: true)
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
            .subscribe(onNext: { vc, type in
                vc.isInitLoading = false
                vc.resultCollectionView.performBatchUpdates({
                    vc.resultCollectionView.reloadSections(IndexSet(integer: 0))
                })
                vc.emptyResultView.isHidden = !((viewModel.groupList?.count == 0) ?? true)
                print("fetched!")
                switch type {
                case .refresh:
                    vc.showToast(message: "새로고침을 성공하였습니다.", type: .normal)
                case .remove(let message):
                    vc.showToast(message: message, type: .normal)
                default:
                    return
                }
            })
            .disposed(by: bag)
        
        output
            .didStartFetching
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.isInitLoading = true
                vc.resultCollectionView.reloadData()
                vc.emptyResultView.isHidden = true
            })
            .disposed(by: bag)
        
        output
            .needReloadItemAt //이걸 리로드로 하면 약간의 flicker가 발생함. without animation으로 할까?
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                UIView.performWithoutAnimation {
                    vc.resultCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            })
            .disposed(by: bag)
        
        output
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message, type: .normal)
            })
            .disposed(by: bag)
        
        output
            .didSuccessOnlineStateChange
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (index, isSuccess) in
                guard let self,
                      var group = viewModel.groupList?[index],
                      let cell = self.resultCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? JoinedGroupCell else { return }
                
                let outerSwitchBag = DisposeBag()
                cell.outerSwitchBag = outerSwitchBag
                
                cell.onlineSwitch.isOn = group.isOnline
                cell.onlineButton.setTitle("\(group.onlineCount)", for: .normal)
                
                cell.onlineSwitch.rx.isOn
                    .skip(1)
                    .asObservable() //초기값 무시
                    .subscribe(onNext: { isOn in
                        cell.onlineSwitch.isUserInteractionEnabled = false
                        if isOn {
                            self.becameOnlineStateAt.onNext(index)
                        } else {
                            self.becameOfflineStateAt.onNext(index)
                        }
                    })
                .disposed(by: outerSwitchBag)
                cell.onlineSwitch.isUserInteractionEnabled = true
            })
            .disposed(by: bag)
    }
    
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(emptyResultView)
        self.view.addSubview(resultCollectionView)
    }
    
    func configureLayout() {
        emptyResultView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        resultCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        refreshRequired.onNext(())
    }
}

extension GroupListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isInitLoading {
            return Int(UIScreen.main.bounds.height/250)*2
        }
        return viewModel?.groupList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JoinedGroupCell.reuseIdentifier, for: indexPath) as? JoinedGroupCell else { return UICollectionViewCell() }
        if isInitLoading {
            cell.startSkeletonAnimation()
            return cell
        }
        guard let item = viewModel?.groupList?[indexPath.item] else { return UICollectionViewCell() }
        cell.stopSkeletonAnimation()
        print("fetch cel")
        // 이전에 바인딩되있던게 있다면 전부 버림
        cell.bag = nil
        cell.fill(
            title: item.groupName,
            tag: item.groupTags.map { "#\($0.name)" }.joined(separator: " "),
            memCount: "\(item.totalCount)/\(item.limitCount)",
            leaderName: item.leaderName,
            onlineCount: "\(item.onlineCount)",
            isOnline: item.isOnline
        ) //값먼저 주고
        
        // 새로 바인딩..!
        let cellBag = DisposeBag()
        let outerSwitchBag = DisposeBag()
        
        cell.bag = cellBag
        cell.outerSwitchBag = outerSwitchBag
        
        cell.onlineSwitch.rx.isOn
            .skip(1)
            .asObservable() //초기값은 무시
            .withUnretained(self)
            .subscribe(onNext: { vc, isOn in
                cell.onlineSwitch.isUserInteractionEnabled = false
                if isOn {
                    vc.becameOnlineStateAt.onNext(indexPath.item)
                } else {
                    vc.becameOfflineStateAt.onNext(indexPath.item)
                }
            })
        .disposed(by: outerSwitchBag)
        
        viewModel?.fetchImage(key: item.groupImageUrl)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { data in
                cell.fill(image: UIImage(data: data))
            })
            .disposed(by: cellBag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tappedItemAt.onNext(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: JoinedGroupSectionHeaderView.reuseIdentifier, for: indexPath) as? JoinedGroupSectionHeaderView else { return UICollectionReusableView() }
        if isInitLoading {
            view.startSkeletonAnimation()
            return view
        }
        view.stopSkeletonAnimation()
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
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 20, trailing: 7)
        
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

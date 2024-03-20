//
//  NotificationViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/31.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationViewController: UIViewController {
    var bag = DisposeBag()
    var nowLoading = true

    var viewModel: NotificationViewModel?
    
    var didAllowBtnTappedAt = PublishSubject<Int?>()
    var didDenyBtnTappedAt = PublishSubject<Int?>()

    var refreshRequired = PublishSubject<Void>()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    var emptyResultView: EmptyResultView = {
        let view = EmptyResultView(text: "그룹 신청이 없습니다.")
        view.isHidden = true
        return view
    }()
    
    lazy var resultCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(GroupJoinNotificationCell.self, forCellWithReuseIdentifier: GroupJoinNotificationCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .black
        return item
    }()
    
    convenience init(viewModel: NotificationViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureLayout()

        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "그룹 신청 관리"
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            viewModel?.actions.finishScene?()
        }
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = NotificationViewModel.Input(
            viewDidLoad: Observable.just(()),
            didTapAllowBtnAt: didAllowBtnTappedAt.asObservable(),
            didTapDenyBtnAt: didDenyBtnTappedAt.asObservable(),
            refreshRequired: refreshRequired.asObservable(),
            backBtnTapped: backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchJoinApplyList
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, type in
                vc.nowLoading = false
                vc.resultCollectionView.performBatchUpdates {
                    vc.resultCollectionView.reloadSections(IndexSet(integer: 0))
                }
                vc.emptyResultView.isHidden = !(viewModel.joinAppliedList?.count == 0)

                switch type {
                case .refresh:
                    vc.showToast(message: "새로고침을 성공하였습니다.", type: .normal)
                default:
                    return
                }
            })
            .disposed(by: bag)
        
        output
            .needRemoveAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.resultCollectionView.performBatchUpdates ({
                    vc.resultCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }, completion: { _ in
                    UIView.performWithoutAnimation {
                        vc.resultCollectionView.reloadSections(IndexSet(integer: 0))
                    }
                })
                vc.emptyResultView.setAnimatedIsHidden(!(viewModel.joinAppliedList?.count == 0))
            })
            .disposed(by: bag)
        
        output
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message.text, type: Message.toToastType(state: message.state))
            })
            .disposed(by: bag)
    }
    
    @objc func backBtnAction() {
        viewModel?.actions.pop?()
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
        if sender.isRefreshing {
            sender.endRefreshing()
        }
        nowLoading = true
        emptyResultView.isHidden = true
        resultCollectionView.reloadData()
        refreshRequired.onNext(())
    }
}

extension NotificationViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if nowLoading {
            return Int(UIScreen.main.bounds.height/122)
        }
        return viewModel?.joinAppliedList?.count ?? Int()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupJoinNotificationCell.reuseIdentifier, for: indexPath) as? GroupJoinNotificationCell else { return UICollectionViewCell() }
        
        if nowLoading {
            cell.startSkeletonAnimation()
            return cell
        }
        
        guard let item = viewModel?.joinAppliedList?[indexPath.item] else { return UICollectionViewCell() }
        cell.stopSkeletonAnimation()
        
        let bag = DisposeBag()
        cell.fill(bag: bag, indexPath: indexPath, isAllowTapped: didAllowBtnTappedAt, isDenyTapped: didDenyBtnTappedAt)
        cell.fill(groupName: item.groupName, memberName: item.memberName, memberDesc: item.memberDescription)
        
        if let url = item.memberProfileImageUrl {
            viewModel?.fetchImage(key: url)
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onSuccess: { data in
                    cell.fill(memberImage: UIImage(data: data))
                })
                .disposed(by: bag)
        }
        
        return cell
    }

}

extension NotificationViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(122))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)

        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

extension NotificationViewController: UIGestureRecognizerDelegate {}

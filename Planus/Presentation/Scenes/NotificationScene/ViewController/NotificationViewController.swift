//
//  NotificationViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/31.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationViewController: UIViewController {
    private let bag = DisposeBag()
    var nowLoading = true

    private var viewModel: NotificationViewModel?
    private var notificationView: NotificationView?
    
    private let didAllowBtnTappedAt = PublishRelay<Int?>()
    private let didDenyBtnTappedAt = PublishRelay<Int?>()
    private let refreshRequired = PublishRelay<Void>()
    
    convenience init(viewModel: NotificationViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        let view = NotificationView(frame: self.view.frame)
        
        self.view = view
        self.notificationView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "그룹 신청 관리"
        navigationItem.setLeftBarButton(notificationView?.backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            viewModel?.actions.finishScene?()
        }
    }
}

// MARK: - Configure VC
private extension NotificationViewController {
    func configureVC() {
        notificationView?.resultCollectionView.dataSource = self
        notificationView?.resultCollectionView.delegate = self
        
        notificationView?.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
}

// MARK: - bind viewModel
private extension NotificationViewController {
    func bind() {
        guard let viewModel,
              let notificationView else { return }
        
        let input = NotificationViewModel.Input(
            viewDidLoad: Observable.just(()),
            didTapAllowBtnAt: didAllowBtnTappedAt.asObservable(),
            didTapDenyBtnAt: didDenyBtnTappedAt.asObservable(),
            refreshRequired: refreshRequired.asObservable(),
            backBtnTapped: notificationView.backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchJoinApplyList
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, type in
                vc.reloadApplies(type: type)
            })
            .disposed(by: bag)
        
        output
            .needRemoveAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.removeApplyAt(index: index)
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
}

// MARK: - Actions
private extension NotificationViewController {
    func reloadApplies(type: FetchType) {
        nowLoading = false
        notificationView?.resultCollectionView.performBatchUpdates {
            notificationView?.resultCollectionView.reloadSections(IndexSet(integer: 0))
        }
        notificationView?.emptyResultView.isHidden = !(viewModel?.joinAppliedList?.count == 0)

        switch type {
        case .refresh:
            showToast(message: "새로고침을 성공하였습니다.", type: .normal)
        default:
            return
        }
    }
    
    func removeApplyAt(index: Int) {
        notificationView?.resultCollectionView.performBatchUpdates ({
            notificationView?.resultCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }, completion: { _ in
            UIView.performWithoutAnimation { [weak self] in
                self?.notificationView?.resultCollectionView.reloadSections(IndexSet(integer: 0))
            }
        })
        notificationView?.emptyResultView.setAnimatedIsHidden(!(viewModel?.joinAppliedList?.count == 0))
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        if sender.isRefreshing {
            sender.endRefreshing()
        }
        nowLoading = true
        notificationView?.emptyResultView.isHidden = true
        notificationView?.resultCollectionView.reloadData()
        refreshRequired.accept(())
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

extension NotificationViewController: UIGestureRecognizerDelegate {}

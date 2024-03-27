//
//  MyGroupListViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/31.
//

import UIKit
import RxCocoa
import RxSwift

final class MyGroupListViewController: UIViewController {
    
    private var viewModel: MyGroupListViewModel?
    private var myGroupListView: MyGroupListView?

    private var bag = DisposeBag()
        
    private var isInitLoading = false
    private var tappedItemAt = PublishRelay<Int>()
    private var becameOnlineStateAt = PublishRelay<Int>()
    private var becameOfflineStateAt = PublishRelay<Int>()

    private var refreshRequired = PublishSubject<Void>()
    
    convenience init(viewModel: MyGroupListViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        let view = MyGroupListView(frame: self.view.frame)
        
        self.view = view
        self.myGroupListView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "내가 참여중인 그룹"
        navigationItem.setRightBarButton(myGroupListView?.notificationButton, animated: true)
    }
}

// MARK: Actions
private extension MyGroupListViewController {
    @objc func refresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        refreshRequired.onNext(())
    }
}

// MARK: Configure VC
private extension MyGroupListViewController {
    func configureVC() {
        myGroupListView?.resultCollectionView.dataSource = self
        myGroupListView?.resultCollectionView.delegate = self
        
        myGroupListView?.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    func bind() {
        guard let viewModel,
              let myGroupListView else { return }
        
        let input = MyGroupListViewModel.Input(
            viewDidLoad: Observable.just(()),
            tappedAt: tappedItemAt.asObservable(),
            becameOnlineStateAt: becameOnlineStateAt.asObservable(),
            becameOfflineStateAt: becameOfflineStateAt.asObservable(),
            refreshRequired: refreshRequired.asObservable(),
            notificationBtnTapped: myGroupListView.notificationButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchJoinedGroup
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, type in
                vc.isInitLoading = false
                myGroupListView.resultCollectionView.performBatchUpdates({
                    myGroupListView.resultCollectionView.reloadSections(IndexSet(integer: 0))
                })
                myGroupListView.emptyResultView.isHidden = !((viewModel.groupList?.count == 0) ?? true)

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
                myGroupListView.resultCollectionView.reloadData()
                myGroupListView.emptyResultView.isHidden = true
            })
            .disposed(by: bag)
        
        output
            .needReloadItemAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                UIView.performWithoutAnimation {
                    myGroupListView.resultCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
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
                      let cell = myGroupListView.resultCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? MyGroupCell else { return }
                
                let outerSwitchBag = DisposeBag()
                cell.outerSwitchBag = outerSwitchBag
                
                cell.onlineSwitch.isOn = group.isOnline
                cell.onlineButton.setTitle("\(group.onlineCount)", for: .normal)
                
                cell.onlineSwitch.rx.isOn
                    .skip(1)
                    .asObservable()
                    .subscribe(onNext: { isOn in
                        cell.onlineSwitch.isUserInteractionEnabled = false
                        if isOn {
                            self.becameOnlineStateAt.accept(index)
                        } else {
                            self.becameOfflineStateAt.accept(index)
                        }
                    })
                .disposed(by: outerSwitchBag)
                cell.onlineSwitch.isUserInteractionEnabled = true
            })
            .disposed(by: bag)
    }
}
extension MyGroupListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyGroupCell.reuseIdentifier, for: indexPath) as? MyGroupCell else { return UICollectionViewCell() }
        if isInitLoading {
            cell.startSkeletonAnimation()
            return cell
        }
        cell.stopSkeletonAnimation()
        
        guard let viewModel,
              let item = viewModel.groupList?[indexPath.item] else { return UICollectionViewCell() }

        cell.bag = nil
        cell.fill(
            title: item.groupName,
            tag: item.groupTags.map { "#\($0.name)" }.joined(separator: " "),
            memCount: "\(item.totalCount)/\(item.limitCount)",
            leaderName: item.leaderName,
            onlineCount: "\(item.onlineCount)",
            isOnline: item.isOnline,
            imgFetcher: viewModel.fetchImage(key: item.groupImageUrl)
        )
        
        let outerSwitchBag = DisposeBag()
        cell.outerSwitchBag = outerSwitchBag
        
        cell.onlineSwitch.rx.isOn
            .skip(1)
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { vc, isOn in
                cell.onlineSwitch.isUserInteractionEnabled = false
                if isOn {
                    vc.becameOnlineStateAt.accept(indexPath.item)
                } else {
                    vc.becameOfflineStateAt.accept(indexPath.item)
                }
            })
        .disposed(by: outerSwitchBag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tappedItemAt.accept(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MyGroupListSectionHeaderView.reuseIdentifier, for: indexPath) as? MyGroupListSectionHeaderView else { return UICollectionReusableView() }
        if isInitLoading {
            view.startSkeletonAnimation()
            return view
        }
        view.stopSkeletonAnimation()
        view.fill(title: "그룹 이미지 상단의 슬라이드를 움직여 스터디를 시작하세요")
        return view
    }
}

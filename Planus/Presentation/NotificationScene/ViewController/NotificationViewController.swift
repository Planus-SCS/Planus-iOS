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
    var bag = DisposeBag()

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
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
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

    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = NotificationViewModel.Input(
            viewDidLoad: Observable.just(()),
            didTapAllowBtnAt: didAllowBtnTappedAt.asObservable(),
            didTapDenyBtnAt: didDenyBtnTappedAt.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchJoinApplyList
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.resultCollectionView.reloadData()
                if viewModel.joinApplyList?.count == 0 {
                    vc.emptyResultView.isHidden = false
                } else {
                    vc.emptyResultView.isHidden = true
                }
            })
            .disposed(by: bag)
    }
    
    @objc func backBtnAction() {
        self.navigationController?.popViewController(animated: true)
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
        self.resultCollectionView.reloadData()
    }
}

extension NotificationViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.joinApplyList?.count ?? Int()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewModel?.joinApplyList?[indexPath.item],
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupJoinNotificationCell.reuseIdentifier, for: indexPath) as? GroupJoinNotificationCell else { return UICollectionViewCell() }
        
        var bag = DisposeBag()
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

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (refreshControl.isRefreshing) {
            self.refreshControl.endRefreshing()
            refreshRequired.onNext(())
        }
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

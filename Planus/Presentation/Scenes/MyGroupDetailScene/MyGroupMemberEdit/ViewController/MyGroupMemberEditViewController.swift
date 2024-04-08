//
//  MyGroupMemberEditViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit
import RxSwift

final class MyGroupMemberEditViewController: UIViewController {
    
    private var bag = DisposeBag()
    
    private var viewModel: MyGroupMemberEditViewModel?
    private var myGroupMemberEditView: MyGroupMemberEditView?
    
    private var didTappedResignButton = PublishSubject<Int>()
    
    convenience init(viewModel: MyGroupMemberEditViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let view = MyGroupMemberEditView(frame: self.view.frame)
        self.view = view
        self.myGroupMemberEditView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "그룹 멤버 관리"
        
        navigationItem.setLeftBarButton(myGroupMemberEditView?.backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

// MARK: - Configure VC
private extension MyGroupMemberEditViewController {
    func configureVC() {
        myGroupMemberEditView?.memberCollectionView.dataSource = self
    }
}

// MARK: - bind viewModel
private extension MyGroupMemberEditViewController {
    func bind() {
        guard let viewModel,
              let myGroupMemberEditView else { return }
        
        let input = MyGroupMemberEditViewModel.Input(
            viewDidLoad: Observable.just(()),
            didTappedResignButton: didTappedResignButton,
            backBtnTapped: myGroupMemberEditView.backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didFetchMemberList
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                myGroupMemberEditView.memberCollectionView.reloadData()
            })
            .disposed(by: bag)
        
        output
            .didResignedAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                myGroupMemberEditView.memberCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            })
            .disposed(by: bag)
        
        output
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message)
            })
            .disposed(by: bag)
    }
}

// MARK: - collection View
extension MyGroupMemberEditViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.memberList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel,
              let item = viewModel.memberList?[indexPath.item],
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyGroupMemberEditCell.reuseIdentifier, for: indexPath) as? MyGroupMemberEditCell else { return UICollectionViewCell() }
        
        cell.fill(
            name: item.nickname,
            introduce: item.description,
            isCaptin: item.isLeader,
            imgFetcher: viewModel.fetchImage(key: item.profileImageUrl ?? String())
            )

        cell.fill { [weak self] in
            self?.showPopUp(title: "[\(item.nickname)] 를 강제 탈퇴 하시겠습니까?", message: "멤버 탈퇴는 이후에 취소가 불가능합니다", alertAttrs: [
                CustomAlertAttr(title: "취소", actionHandler: {}, type: .normal),
                CustomAlertAttr(title: "탈퇴", actionHandler: { self?.didTappedResignButton.onNext(indexPath.item)}, type: .warning)
            ])
        }
        return cell
    }
}

extension MyGroupMemberEditViewController: UIGestureRecognizerDelegate {}

//
//  MyPageMainViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import UIKit
import RxSwift
import RxCocoa
import AuthenticationServices

final class MyPageMainViewController: UIViewController {
    var bag = DisposeBag()
    var headerBag: DisposeBag?
    var viewModel: MyPageMainViewModel?
    
    var didReceiveAppleAuthCode = PublishRelay<Data>()
        
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.backgroundColor = .planusBackgroundColor
        cv.register(MyPageMainSelectableCell.self, forCellWithReuseIdentifier: MyPageMainSelectableCell.reuseIdentifier)
        cv.register(MyPageMainSwitchableCell.self, forCellWithReuseIdentifier: MyPageMainSwitchableCell.reuseIdentifier)
        cv.register(MyPageMainHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MyPageMainHeaderView.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .planusBlack
        return item
    }()
    
    lazy var editButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "수정", style: .plain, target: nil, action: nil)
        item.tintColor = .planusTintBlue
        return item
    }()
    
    convenience init(viewModel: MyPageMainViewModel) {
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
        
        navigationItem.title = "마이 페이지"
        navigationItem.setRightBarButton(editButton, animated: false)
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            viewModel?.actions.finish?()
        }
    }
}

// MARK: configure
private extension MyPageMainViewController {
    func bind() {
        guard let viewModel else { return }
        
        let input = MyPageMainViewModel.Input(
            viewDidLoad: Observable.just(()),
            editBtnTapped: editButton.rx.tap.asObservable(),
            didSelectedAt: collectionView.rx.itemSelected.map { $0.item }.asObservable(),
            didReceiveAppleAuthCode: didReceiveAppleAuthCode.asObservable(),
            backBtnTapped: backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didRefreshUserProfile
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.collectionView.reloadSections(IndexSet(0...0))
            })
            .disposed(by: bag)
        
        output
            .didRequireAppleSignInWithRequest
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, request in
                vc.showASAuthController(request: request)
            })
            .disposed(by: bag)
        
        output
            .showPopUp
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, popUp in
                vc.showPopUp(
                    title: popUp.title,
                    message: popUp.message,
                    alertAttrs: popUp.alertAttrs
                )
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.backgroundColor = .planusBackgroundColor
        self.view.addSubview(collectionView)
    }
    
    func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

extension MyPageMainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.titleList.count ?? 0

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewModel?.titleList[indexPath.row],
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MyPageMainSelectableCell.reuseIdentifier,
                for: indexPath
              ) as? MyPageMainSelectableCell else { return UICollectionViewCell() }
              
        cell.fill(title: item.title)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let viewModel,
              let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MyPageMainHeaderView.reuseIdentifier, for: indexPath) as? MyPageMainHeaderView else { return UICollectionReusableView() }
        
        view.memberProfileHeaderView.nameLabel.text = viewModel.name
        
        if let desc = viewModel.introduce,
           !desc.isEmpty {
            view.memberProfileHeaderView.introduceLabel.text = desc
            view.memberProfileHeaderView.introduceLabel.alpha = 1
        } else {
            view.memberProfileHeaderView.introduceLabel.text = "자기소개를 작성해주세요!"
            view.memberProfileHeaderView.introduceLabel.alpha = 0.6
        }

        view.memberProfileHeaderView.introduceLabel.sizeToFit()
        
        if let imageURL = viewModel.imageURL {
            let bag = DisposeBag()
            viewModel.fetchImage(key: imageURL)
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onSuccess: { data in
                    view.memberProfileHeaderView.profileImageView.image = UIImage(data: data)
                })
                .disposed(by: bag)
            self.headerBag = bag
        } else {
            view.memberProfileHeaderView.profileImageView.image = UIImage(named: "DefaultProfileMedium")
        }

        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: self.view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var mockView: MemberProfileHeaderView
        if let desc = viewModel?.introduce,
           !desc.isEmpty {
            mockView = MemberProfileHeaderView(
                mockName: viewModel?.name,
                mockDesc: desc
            )
        } else {
            mockView = MemberProfileHeaderView(
                mockName: viewModel?.name,
                mockDesc: "자기소개를 작성해주세요!"
            )
        }
        
        let estimatedSize = mockView
            .systemLayoutSizeFitting(CGSize(width: self.view.frame.width,
                                            height: 111))
        
        return CGSize(width: self.view.frame.width, height: estimatedSize.height)
    }    
}

extension MyPageMainViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func showASAuthController(request: ASAuthorizationAppleIDRequest) {
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let authCodeData = appleIDCredential.authorizationCode else {
            viewModel?.nowResigning = false
            return
        }

        didReceiveAppleAuthCode.accept(authCodeData)
        
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        viewModel?.nowResigning = false
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension MyPageMainViewController: UIGestureRecognizerDelegate {}

//
//  GroupIntroduceViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift
import RxCocoa

enum GroupIntroduceSectionKind: Int, CaseIterable {
    case info = 0
    case notice
    case member
    
    var title: String {
        switch self {
        case .info:
            return ""
        case .notice:
            return "공지사항"
        case .member:
            return "그룹멤버"
        }
    }
    
    var desc: String {
        switch self {
        case .info:
            return ""
        case .notice:
            return "우리 이렇게 진행해요"
        case .member:
            return "우리 함께해요"
        }
    }
}

final class GroupIntroduceView: UIView {
    let headerHeight: CGFloat = 330
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        cv.register(GroupIntroduceNoticeCell.self,
                    forCellWithReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier)
        
        cv.register(GroupIntroduceMemberCell.self,
                    forCellWithReuseIdentifier: GroupIntroduceMemberCell.reuseIdentifier)
        
        cv.register(GroupIntroduceDefaultHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier)
        
        cv.register(GroupIntroduceInfoHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: GroupIntroduceInfoHeaderView.reuseIdentifier)
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
        return cv
    }()
    
    var stickyFooterView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: 0xF5F5FB)
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowRadius = 2
        return view
    }()
    
    var joinButton: SpringableButton = {
        let button = SpringableButton(frame: .zero)
        button.setTitle("로딩중", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: 0x6495F4)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .black
        return item
    }()
    
    lazy var shareButton: UIBarButtonItem = {
        let image = UIImage(named: "share")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .black
        return item
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Configure View
private extension GroupIntroduceView {
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        
        self.addSubview(collectionView)
        self.addSubview(stickyFooterView)
        
        stickyFooterView.addSubview(joinButton)
    }
    
    func configureLayout() {
        stickyFooterView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(85)
        }
        
        joinButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview().offset(-5)
            $0.height.equalTo(50)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}


// MARK: collectionView layout
private extension GroupIntroduceView {
    func createInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(1), heightDimension: .absolute(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(1),heightDimension: .absolute(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(headerHeight))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    func createNoticeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 30, trailing: 0)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(70))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    func createMemberSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(66))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 26, bottom: 0, trailing: 26)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 85, trailing: 0)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(70))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    func createLayout() -> UICollectionViewLayout {
        return StickyTopCompositionalLayout(headerHeight: headerHeight) { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self,
                  let sectionKind = GroupIntroduceSectionKind(rawValue: sectionIndex) else { return nil }
            
            // MARK: Item Layout
            switch sectionKind {
            case .info:
                return self.createInfoSection()
            case .notice:
                return self.createNoticeSection()
            case .member:
                return self.createMemberSection()
            }
        }
    }
}


final class GroupIntroduceViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var bag = DisposeBag()
    
    var viewModel: GroupIntroduceViewModel?
    var groupIntroduceView: GroupIntroduceView?
    
    var nowLoading: Bool = true
    
    convenience init(viewModel: GroupIntroduceViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        let view = GroupIntroduceView(frame: self.view.frame)
        self.groupIntroduceView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setLeftBarButton(groupIntroduceView?.backButton, animated: false)
        navigationItem.setRightBarButton(groupIntroduceView?.shareButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        configureNavigationBarAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            viewModel?.actions.finishScene?()
        }
    }
}

// MARK: ConfigureVC
private extension GroupIntroduceViewController {
    
    func configureNavigationBarAppearance() {
        let initialAppearance = UINavigationBarAppearance()
        let scrollingAppearance = UINavigationBarAppearance()
        
        scrollingAppearance.configureWithOpaqueBackground()
        scrollingAppearance.backgroundColor = UIColor(hex: 0xF5F5FB)
        
        let initialBarButtonAppearance = UIBarButtonItemAppearance()
        initialBarButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        initialAppearance.configureWithTransparentBackground()
        initialAppearance.buttonAppearance = initialBarButtonAppearance
        
        let scrollingBarButtonAppearance = UIBarButtonItemAppearance()
        scrollingBarButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
        scrollingAppearance.buttonAppearance = scrollingBarButtonAppearance
        
        self.navigationItem.standardAppearance = scrollingAppearance
        self.navigationItem.scrollEdgeAppearance = initialAppearance
        
        self.navigationController?.navigationBar.standardAppearance = scrollingAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = initialAppearance
    }
    
    func configureVC() {
        groupIntroduceView?.collectionView.dataSource = self
    }
    
    func bind() {
        guard let viewModel,
              let groupIntroduceView else { return }
        
        let input = GroupIntroduceViewModel.Input(
            viewDidLoad: Observable.just(()),
            didTappedJoinBtn: groupIntroduceView.joinButton.rx.tap.asObservable(),
            shareBtnTapped: groupIntroduceView.shareButton.rx.tap.asObservable(),
            didTappedBackBtn: groupIntroduceView.backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        Observable.zip(
            output.didGroupInfoFetched.compactMap { $0 },
            output.didGroupMemberFetched.compactMap { $0 }
        )
        .observe(on: MainScheduler.asyncInstance)
        .withUnretained(self)
        .subscribe(onNext: { vc, _ in
            vc.nowLoading = false
            groupIntroduceView.collectionView.reloadSections(IndexSet(0...2))
        })
        .disposed(by: bag)
        
        output
            .isJoinableGroup
            .compactMap { $0 }
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, isJoined in
                vc.setJoinButton(state: isJoined)
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
        
        output
            .showShareMenu
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vc, url in
                vc.showShareActivityVC(with: url)
            })
            .disposed(by: bag)
    }
}

// MARK: Actions
private extension GroupIntroduceViewController {
    func setJoinButton(state: GroupJoinableState) {
        switch state {
        case .isJoined:
            groupIntroduceView?.joinButton.setTitle("그룹 페이지로 이동하기", for: .normal)
        case .notJoined:
            groupIntroduceView?.joinButton.setTitle("그룹가입 신청하기", for: .normal)
        case .full:
            groupIntroduceView?.joinButton.setTitle("빈 자리가 없어요 😭", for: .normal)
            groupIntroduceView?.joinButton.isEnabled = false
        }
    }
    
    func showShareActivityVC(with url: String) {
        var objectsToShare = [String]()
        objectsToShare.append(url)
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
        DispatchQueue.main.async { [weak self] in
            self?.present(activityVC, animated: true)
        }
    }
    
}

extension GroupIntroduceViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionKind = GroupIntroduceSectionKind(rawValue: section) else { return 0 }
        
        switch sectionKind {
        case .info:
            return 0
        case .notice:
            return nowLoading ? 1 : viewModel?.notice != nil ? 1 : 0
        case .member:
            return nowLoading ? 6 : viewModel?.memberList?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionKind = GroupIntroduceSectionKind(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch sectionKind {
        case .info:
            return UICollectionViewCell()
        case .notice:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier, for: indexPath) as? GroupIntroduceNoticeCell else { return UICollectionViewCell() }
            if nowLoading {
                cell.startSkeletonAnimation()
                return cell
            }
            
            guard let item = viewModel?.notice else { return UICollectionViewCell() }
            cell.stopSkeletonAnimation()
            cell.fill(notice: item)
            
            return cell
        case .member:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceMemberCell.reuseIdentifier, for: indexPath) as? GroupIntroduceMemberCell else { return UICollectionViewCell() }
            if nowLoading {
                cell.startSkeletonAnimation()
                return cell
            }
            
            guard let item = viewModel?.memberList?[indexPath.item] else { return UICollectionViewCell() }
            
            cell.stopSkeletonAnimation()
            cell.fill(name: item.name, introduce: item.description, isCaptin: item.isLeader)
            
            if let url = item.profileImageUrl {
                viewModel?.fetchImage(key: url)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onSuccess: { data in
                        cell.fill(image: UIImage(data: data))
                    })
                    .disposed(by: bag)
            } else {
                cell.fill(image: UIImage(named: "DefaultProfileMedium"))
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionKind = GroupIntroduceSectionKind(rawValue: indexPath.section) else { return UICollectionReusableView() }
        
        switch sectionKind {
        case .info:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GroupIntroduceInfoHeaderView.reuseIdentifier, for: indexPath) as? GroupIntroduceInfoHeaderView else { return UICollectionReusableView() }
            
            if nowLoading {
                view.startSkeletonAnimation()
                return view
            }
            view.stopSkeletonAnimation()
            
            view.fill(
                title: viewModel?.groupTitle ?? String(),
                tag: viewModel?.tag ?? String(),
                memCount: viewModel?.memberCount ?? String(),
                captin: viewModel?.captin ?? String()
            )
            if let url = viewModel?.groupImageUrl {
                viewModel?.fetchImage(key: url)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onSuccess: { data in
                        view.fill(image: UIImage(data: data))
                    })
                    .disposed(by: bag)
            }
            return view
        case .notice, .member:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier, for: indexPath) as? GroupIntroduceDefaultHeaderView else { return UICollectionReusableView() }
            if nowLoading {
                view.startSkeletonAnimation()
                return view
            }
            view.stopSkeletonAnimation()
            view.fill(title: sectionKind.title, description: sectionKind.desc)
            return view
        }
    }
}

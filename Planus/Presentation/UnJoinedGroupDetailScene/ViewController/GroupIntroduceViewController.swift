//
//  GroupIntroduceViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift
import RxCocoa
// 컴포지셔널 레이아웃 써서 어엄청 크게 만들자, 디퍼블을 쓸까? 고민되네

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
            return "우리 이렇게 공부해요"
        case .member:
            return "우리 함께해요"
        }
    }
}

struct Member {
    var id: Int
    var name: String
    var isLeader: Bool
    var description: String?
    var profileImageUrl: String?
}

class GroupIntroduceViewController: UIViewController, UIGestureRecognizerDelegate {

    var bag = DisposeBag()
    
    var backButtonTapped = PublishSubject<Void>()
    
    static let headerElementKind = "group-introduce-view-controller-header-kind"
    var headerSize: CGFloat = 330
    
    var viewModel: GroupIntroduceViewModel?
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())

        cv.register(GroupIntroduceNoticeCell.self,
            forCellWithReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier)
        
        cv.register(GroupIntroduceMemberCell.self,
            forCellWithReuseIdentifier: GroupIntroduceMemberCell.reuseIdentifier)
        
        cv.register(GroupIntroduceDefaultHeaderView.self,
                    forSupplementaryViewOfKind: Self.headerElementKind,
                    withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier)
        
        cv.register(GroupIntroduceInfoHeaderView.self,
                    forSupplementaryViewOfKind: Self.headerElementKind,
                    withReuseIdentifier: GroupIntroduceInfoHeaderView.reuseIdentifier)
        cv.dataSource = self
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
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    lazy var shareButton: UIBarButtonItem = {
        let image = UIImage(named: "share")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(shareBtnAction))
        item.tintColor = .black
        return item
    }()
    
    convenience init(viewModel: GroupIntroduceViewModel) {
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
//        self.navigationItem.setLeftBarButton(backButton, animated: false)
//        self.navigationItem.setRightBarButton(shareButton, animated: false)
//        self.navigationItem.title = "dkssddd"
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationItem.setRightBarButton(shareButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self

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
    
    var co: JoinedGroupDetailCoordinator?
    
    func bind() {
        guard let viewModel else { return }
        
        let input = GroupIntroduceViewModel.Input(
            viewDidLoad: Observable.just(()),
            didTappedJoinBtn: joinButton.rx.tap.asObservable(),
            didTappedBackBtn: backButtonTapped.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didGroupInfoFetched
            .compactMap { $0 }
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, _ in
                UIView.performWithoutAnimation {
                    vc.collectionView.reloadSections(IndexSet(0...1))
                }
            })
            .disposed(by: bag)
        
        output
            .didGroupMemberFetched
            .compactMap { $0 }
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, _ in
                UIView.performWithoutAnimation {
                    vc.collectionView.reloadSections(IndexSet(2...2))
                }
            })
            .disposed(by: bag)
        
        output
            .isJoinableGroup
            .compactMap { $0 }
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, isJoined in
                if isJoined {
                    vc.joinButton.setTitle("그룹 페이지로 이동하기", for: .normal)
                } else {
                    vc.joinButton.setTitle("그룹가입 신청하기", for: .normal)
                }
            })
            .disposed(by: bag)
        
        output
            .showGroupDetailPage
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, id in
                vc.co = JoinedGroupDetailCoordinator(navigationController: vc.navigationController!)
                vc.co?.start(id: id)
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
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(collectionView)
        self.view.addSubview(stickyFooterView)
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
    
    @objc func backBtnAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func shareBtnAction() {
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
            return viewModel?.notice != nil ? 1 : 0
        case .member:
            return viewModel?.memberList?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionKind = GroupIntroduceSectionKind(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch sectionKind {
        case .info:
            return UICollectionViewCell()
        case .notice:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier, for: indexPath) as? GroupIntroduceNoticeCell,
                  let item = viewModel?.notice else { return UICollectionViewCell() }
            cell.fill(notice: item)
            return cell
        case .member:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceMemberCell.reuseIdentifier, for: indexPath) as? GroupIntroduceMemberCell,
                  let item = viewModel?.memberList?[indexPath.item] else { return UICollectionViewCell() }

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
        
        guard kind == Self.headerElementKind,
              let sectionKind = GroupIntroduceSectionKind(rawValue: indexPath.section) else { return UICollectionReusableView() }
        
        switch sectionKind {
        case .info:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: Self.headerElementKind, withReuseIdentifier: GroupIntroduceInfoHeaderView.reuseIdentifier, for: indexPath) as? GroupIntroduceInfoHeaderView else { return UICollectionReusableView() }
            // 이부분 아무래도 셀로 만들어야할거같다.. 네트워크 받아오면 업댓해야되서 그전까지 비워놔야한다,,, 그냥 빈화면으로 보여줄까? 것도 낫베드긴한디
            view.fill(
                title: viewModel?.groupTitle ?? "",
                tag: viewModel?.tag ?? "",
                memCount: viewModel?.memberCount ?? "",
                captin: viewModel?.captin ?? ""
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
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: Self.headerElementKind, withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier, for: indexPath) as? GroupIntroduceDefaultHeaderView else { return UICollectionReusableView() }
            view.fill(title: sectionKind.title, description: sectionKind.desc)
            return view
        }
    }
}

// MARK: Generate layout

extension GroupIntroduceViewController {
    private func createInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(1), heightDimension: .absolute(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(1),heightDimension: .absolute(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(330))

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: Self.headerElementKind,
            alignment: .top
        )

        section.boundarySupplementaryItems = [sectionHeader]
                
        return section
    }
    
    private func createNoticeSection() -> NSCollectionLayoutSection {
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
            elementKind: Self.headerElementKind,
            alignment: .top
        )

        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }
    
    private func createMemberSection() -> NSCollectionLayoutSection {
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
            elementKind: Self.headerElementKind,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return StickyTopCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
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


class StickyTopCompositionalLayout: UICollectionViewCompositionalLayout {
    
    var headerSize: CGFloat = 330
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        guard let offset = collectionView?.contentOffset, let stLayoutAttributes = layoutAttributes else {
            return layoutAttributes
        }
        
        if offset.y < 0 {
            for attributes in stLayoutAttributes
            where attributes.representedElementKind == GroupIntroduceViewController.headerElementKind
            && attributes.indexPath.section == 0 {
                let width = collectionView!.frame.width
                let height = headerSize - offset.y
                attributes.frame = CGRect(x: 0, y: offset.y, width: width, height: height)
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

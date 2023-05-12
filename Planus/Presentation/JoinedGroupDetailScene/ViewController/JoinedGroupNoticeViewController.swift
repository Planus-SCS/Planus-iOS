//
//  JoinedGroupNoticeViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit
import RxSwift

enum JoinedGroupNoticeSectionKind: Int {
    case notice = 0
    case member
    
    var title: String {
        switch self {
        case .notice:
            return " "
        case .member:
            return " "
        }
    }
    
    var desc: String {
        switch self {
        case .notice:
            return "우리 이렇게 함께해요"
        case .member:
            return "우리 함께해요"
        }
    }
}

class JoinedGroupNoticeViewController: NestedScrollableViewController {
    var bag = DisposeBag()
    static let headerElementKind = "joined-group-notice-header-kind"
    
    var viewModel: JoinedGroupNoticeViewModel?
    
    var noticeEditButtonTapped = PublishSubject<Void>()
    var memberEditButtonTapped = PublishSubject<Void>()
    
    lazy var noticeCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createNoticeLayout())
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
        cv.register(GroupIntroduceNoticeCell.self, forCellWithReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier)
        cv.register(JoinedGroupMemberCell.self, forCellWithReuseIdentifier: JoinedGroupMemberCell.reuseIdentifier)
        cv.register(GroupIntroduceDefaultHeaderView.self, forSupplementaryViewOfKind: Self.headerElementKind, withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    convenience init(viewModel: JoinedGroupNoticeViewModel) {
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
    
    func bind() {
        guard let viewModel else { return }
        
        let input = JoinedGroupNoticeViewModel.Input(viewDidLoad: Observable.just(()))
        
        let output = viewModel.transform(input: input)
        
        output
            .noticeFetched
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.noticeCollectionView.reloadSections(IndexSet(0...0))
            })
            .disposed(by: bag)
        
        output
            .didFetchMemberList
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.noticeCollectionView.reloadSections(IndexSet(1...1))
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.addSubview(noticeCollectionView)
    }
    
    func configureLayout() {
        noticeCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension JoinedGroupNoticeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionKind = JoinedGroupNoticeSectionKind(rawValue: section) else { return 0 }
        switch sectionKind {
        case .notice:
            return (viewModel?.notice != nil) ? 1 : 0
        case .member:
            return viewModel?.memberList?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionKind = JoinedGroupNoticeSectionKind(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch sectionKind {
        case .notice:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier, for: indexPath) as? GroupIntroduceNoticeCell else { return UICollectionViewCell() }
            cell.fill(notice: (try? viewModel?.notice.value()) ?? "")
            return cell
        case .member:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JoinedGroupMemberCell.reuseIdentifier, for: indexPath) as? JoinedGroupMemberCell,
                  let item = viewModel?.memberList?[indexPath.item] else { return UICollectionViewCell() }
            
            cell.fill(name: item.nickname, introduce: item.description, isCaptin: item.isLeader, isOnline: item.isOnline)
            
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
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: Self.headerElementKind, withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier, for: indexPath) as? GroupIntroduceDefaultHeaderView,
              let sectionKind = JoinedGroupNoticeSectionKind(rawValue: indexPath.section)
        else { return UICollectionReusableView() }
        
        view.fill(title: sectionKind.title, description: sectionKind.desc, isCaptin: false)
        switch sectionKind {
        case .notice:
            view.fill { [weak self] in
                self?.noticeEditButtonTapped.onNext(())
            }
        case .member:
            view.fill { [weak self] in
                self?.memberEditButtonTapped.onNext(())
            }
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let networkManager = NetworkManager()
        let useCase1 = DefaultCreateMonthlyCalendarUseCase()
        let useCase2 = DefaultReadTodoListUseCase(todoRepository: TestTodoDetailRepository(apiProvider: networkManager))
        let useCase3 = DefaultDateFormatYYYYMMUseCase()
        let keyChainManager = KeyChainManager()
        
        let tokenRepo = DefaultTokenRepository(apiProvider: networkManager, keyChainManager: keyChainManager)
        let useCase4 = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let useCase5 = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        
        let vm = MemberProfileViewModel(
            createMonthlyCalendarUseCase: useCase1,
            fetchTodoListUseCase: useCase2,
            dateFormatYYYYMMUseCase: useCase3,
            getTokenUseCase: useCase4,
            refreshTokenUseCase: useCase5
        )
        let vc = MemberProfileViewController(viewModel: vm)
        self.navigationController?.pushViewController(vc, animated: true)
        return false
    }
}


// MARK: Compositional Layout Generator

extension JoinedGroupNoticeViewController {
    private func createNoticeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 0, bottom: 30, trailing: 0)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(60))
        
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
        section.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 0)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(60))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: Self.headerElementKind,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }
    
    private func createNoticeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self,
                  let sectionKind = JoinedGroupNoticeSectionKind(rawValue: sectionIndex) else { return nil }
            
            // MARK: Item Layout
            switch sectionKind {
            case .notice:
                return self.createNoticeSection()
            case .member:
                return self.createMemberSection()
            }
        }
    }
}

//
//  GroupIntroduceViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

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
    var imageName: String
    var name: String
    var isCap: Bool
    var desc: String
}

class GroupIntroduceViewController: UIViewController {
    var memberTestSource: [Member] = [
        Member(imageName: "member1", name: "기정이짱짱", isCap: true, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member2", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member3", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member4", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member5", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member6", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member7", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member8", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member9", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member10", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member11", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member12", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개"),
        Member(imageName: "member13", name: "이름름", isCap: false, desc: "자기소개자기소개자기소개자기소개자기소개자기소개")
    ]
    static let headerElementKind = "group-introduce-view-controller-header-kind"
    var headerSize: CGFloat = 330
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
//        cv.register(
//            GroupIntroduceInfoCell.self,
//            forCellWithReuseIdentifier: GroupIntroduceInfoCell.reuseIdentifier
//        )
        
        cv.register(
            GroupIntroduceNoticeCell.self,
            forCellWithReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier
        )
        
        cv.register(
            GroupIntroduceMemberCell.self,
            forCellWithReuseIdentifier: GroupIntroduceMemberCell.reuseIdentifier
        )
        cv.register(
            GroupIntroduceDefaultHeaderView.self,
            forSupplementaryViewOfKind: Self.headerElementKind,
            withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier
        )
        cv.register(GroupIntroduceInfoHeaderView.self, forSupplementaryViewOfKind: Self.headerElementKind, withReuseIdentifier: GroupIntroduceInfoHeaderView.reuseIdentifier)
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
    
    var joinButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("그룹 참여 신청하기", for: .normal)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureLayout()
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
            $0.edges.equalToSuperview()
        }
    }
}

extension GroupIntroduceViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionKind = GroupIntroduceSectionKind(rawValue: section)
        switch sectionKind {
        case .info:
            return 0
        case .notice:
            return 1
        case .member:
            return memberTestSource.count
        case .none:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionKind = GroupIntroduceSectionKind(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch sectionKind {
        case .info:
            return UICollectionViewCell()
        case .notice:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier, for: indexPath) as? GroupIntroduceNoticeCell else { return UICollectionViewCell() }
            cell.fill(notice: """
함께하는 코딩 스터디, 참여해보세요!
코딩 초보를 위한 스터디 그룹, 지금 모집합니다!
함께 성장하는 코딩 스터디, 참여 신청 바로 받습니다!

스터디 모임은 일주일에 한 번, 정기적으로 진행됩니다.

각 참여자는 매주 주어지는 과제를 해결하고, 그 결과물을 다음 모임에 공유합니다.

참여자끼리의 질문과 답변, 상호 피드백 등을 통해 서로의 실력을 향상시키고, 동기부여를 높입니다.

스터디 모임에서는 주로 프로그래밍 언어, 알고리즘, 자료구조 등에 대한 학습과 실습을 진행합니다.

참여 신청은 모집글에 댓글로 남겨주시거나, 개설자의 연락처로 문의해주시면 됩니다.
""")
            return cell
        case .member:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupIntroduceMemberCell.reuseIdentifier, for: indexPath) as? GroupIntroduceMemberCell else { return UICollectionViewCell() }
            let item = memberTestSource[indexPath.item]
            cell.fill(name: item.name, introduce: item.desc, isCaptin: item.isCap)
            cell.fill(image: UIImage(named: "DefaultProfileMedium")!)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == Self.headerElementKind,
              let sectionKind = GroupIntroduceSectionKind(rawValue: indexPath.section) else { return UICollectionReusableView() }
        
        switch sectionKind {
        case .info:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: Self.headerElementKind, withReuseIdentifier: GroupIntroduceInfoHeaderView.reuseIdentifier, for: indexPath) as? GroupIntroduceInfoHeaderView else { return UICollectionReusableView() }
            view.fill(title: "가보자네카라쿠베베", tag: "#태그개수수수수 #네개까지지지지 #제한하는거다다\n#어때아무글자텍스트테스트 #오개까지아무글자텍스", memCount: "1/4", captin: "기정이짱짱")
            view.fill(image: UIImage(named: "groupTest1")!)
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
        section.contentInsets = .init(top: 0, leading: 0, bottom: 50, trailing: 0)
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

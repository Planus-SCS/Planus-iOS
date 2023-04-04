//
//  JoinedGroupDetailViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit
import RxSwift

enum JoinedGroupNoticeSectionKind: Int {
    case notice = 0
    case member
    
    var title: String {
        switch self {
        case .notice:
            return "공지사항"
        case .member:
            return "그룹멤버"
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

class JoinedGroupDetailViewController: UIViewController {
    static let headerElementKind = "joined-group-detail-view-controller-header-kind"

    var viewModel: JoinedGroupDetailViewModel?
    
    lazy var innerScrollView: UIScrollView = noticeCollectionView
    var innerScrollingDownDueToOuterScroll = false
    
    lazy var outerScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.backgroundColor = UIColor(hex: 0xF5F5FB)
        scrollView.delegate = self
        return scrollView
    }()
    
    var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: 0xF5F5FB)
        return view
    }()
    
    lazy var horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.backgroundColor = .systemBackground
        scrollView.delegate = self
        scrollView.decelerationRate = .fast
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    var headerView = JoinedGroupDetailHeaderView(frame: .zero)
    var headerTabView = JoinedGroupDetailHeaderTabView(frame: .zero)
    
    lazy var noticeCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createNoticeLayout())
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
        cv.register(GroupIntroduceNoticeCell.self, forCellWithReuseIdentifier: GroupIntroduceNoticeCell.reuseIdentifier)
        cv.register(GroupIntroduceMemberCell.self, forCellWithReuseIdentifier: GroupIntroduceMemberCell.reuseIdentifier)
        cv.register(GroupIntroduceDefaultHeaderView.self, forSupplementaryViewOfKind: Self.headerElementKind, withReuseIdentifier: GroupIntroduceDefaultHeaderView.reuseIdentifier)
        cv.dataSource = noticeCollectionViewDataSource
        cv.delegate = self
        return cv
    }()
    
    lazy var calendarCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.register(DailyCalendarCell.self, forCellWithReuseIdentifier: DailyCalendarCell.identifier)
        cv.dataSource = calendarCollectionViewDataSource
        cv.delegate = self
        return cv
    }()
    
    lazy var noticeCollectionViewDataSource: JoinedGroupNoticeDataSource = {
        let dataSource = JoinedGroupNoticeDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    lazy var calendarCollectionViewDataSource: CalendarDataSource = {
        let dataSource = CalendarDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    convenience init(viewModel: JoinedGroupDetailViewModel) {
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
        self.view.backgroundColor = .white
        configureView()
        configureLayout()
        
        testSetView()
    }
    
    func testSetView() {
        headerView.titleImageView.image = UIImage(named: "groupTest1")
        headerView.tagLabel.text = "#태그개수수수수 #네개까지지지지 #제한하는거다다 #어때아무글자텍스트테스트 #오개까지아무글자텍스"
        headerView.memberCountButton.setTitle("4/18", for: .normal)
        headerView.captinButton.setTitle("기정이짱짱", for: .normal)
        headerView.onlineButton.setTitle("4", for: .normal)
        
        headerView.memberProfileStack.addArrangedSubview(headerView.generateMemberProfileImageView(image: UIImage(named: "DefaultProfileSmall")))
        headerView.memberProfileStack.addArrangedSubview(headerView.generateMemberProfileImageView(image: UIImage(named: "DefaultProfileSmall")))
        headerView.memberProfileStack.addArrangedSubview(headerView.generateMemberProfileImageView(image: UIImage(named: "DefaultProfileSmall")))
    }
    
    func configureView() {
        self.view.addSubview(outerScrollView)
        
        outerScrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(headerTabView)
        contentView.addSubview(horizontalScrollView)
        horizontalScrollView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(noticeCollectionView)
        horizontalStackView.addArrangedSubview(calendarCollectionView)
    }
    
    func configureLayout() {
        
        outerScrollView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        headerView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(260)
        }
        
        headerTabView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(headerView)
            $0.height.equalTo(40)
        }

        horizontalScrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.view.safeAreaLayoutGuide.snp.height).offset(-40)
            $0.bottom.equalToSuperview()
        }
        
        horizontalStackView.snp.makeConstraints {
            $0.edges.height.equalToSuperview()
        }
        
        noticeCollectionView.snp.makeConstraints {
            $0.width.equalTo(self.view.frame.width)
        }
        
        calendarCollectionView.snp.makeConstraints {
            $0.width.equalTo(self.view.frame.width)
        }
    }
    
    
}

extension JoinedGroupDetailViewController: UICollectionViewDelegate {
    private enum Policy {
        static let floatingPointTolerance = 0.1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // more, less 스크롤 방향의 기준: 새로운 콘텐츠로 스크롤링하면 more, 이전 콘텐츠로 스크롤링하면 less
        // ex) more scroll 한다는 의미: 손가락을 아래에서 위로 올려서 새로운 콘텐츠를 확인한다
        
        if scrollView == self.horizontalScrollView {
            // x값이 바뀐경우
            headerTabView.statusBarView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(scrollView.contentOffset.x/3)
            }
            headerTabView.statusBackGroundView.setNeedsLayout()
        }
                // more, less 스크롤 방향의 기준: 새로운 콘텐츠로 스크롤링하면 more, 이전 콘텐츠로 스크롤링하면 less
                // ex) more scroll 한다는 의미: 손가락을 아래에서 위로 올려서 새로운 콘텐츠를 확인한다
        else {
            let outerScroll = outerScrollView == scrollView
            let innerScroll = !outerScroll
            let moreScroll = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
            let lessScroll = !moreScroll
            
            // outer scroll이 스크롤 할 수 있는 최대값 (이 값을 sticky header 뷰가 있다면 그 뷰의 frame.maxY와 같은 값으로 사용해도 가능)
            let outerScrollMaxOffsetY = outerScrollView.contentSize.height - outerScrollView.frame.height
            let innerScrollMaxOffsetY = innerScrollView.contentSize.height - innerScrollView.frame.height
            
            // 1. outer scroll을 more 스크롤
            // 만약 outer scroll을 more scroll 다 했으면, inner scroll을 more scroll
            if outerScroll && moreScroll {
                print("1")
                guard outerScrollMaxOffsetY < outerScrollView.contentOffset.y + Policy.floatingPointTolerance else { return }
                innerScrollingDownDueToOuterScroll = true
                defer { innerScrollingDownDueToOuterScroll = false }
                
                // innerScrollView를 모두 스크롤 한 경우 stop
                guard innerScrollView.contentOffset.y < innerScrollMaxOffsetY else { return }
                
                innerScrollView.contentOffset.y = innerScrollView.contentOffset.y + outerScrollView.contentOffset.y - outerScrollMaxOffsetY
                outerScrollView.contentOffset.y = outerScrollMaxOffsetY
            }
            
            // 2. outer scroll을 less 스크롤
            // 만약 inner scroll이 less 스크롤 할게 남아 있다면 inner scroll을 less 스크롤
            if outerScroll && lessScroll {
                print("2")

                guard innerScrollView.contentOffset.y > 0 && outerScrollView.contentOffset.y < outerScrollMaxOffsetY else { return }
                innerScrollingDownDueToOuterScroll = true
                defer { innerScrollingDownDueToOuterScroll = false }
                
                // outer scroll에서 스크롤한 만큼 inner scroll에 적용
                innerScrollView.contentOffset.y = max(innerScrollView.contentOffset.y - (outerScrollMaxOffsetY - outerScrollView.contentOffset.y), 0)
                
                // outer scroll은 스크롤 되지 않고 고정
                outerScrollView.contentOffset.y = outerScrollMaxOffsetY
            }
            
            // 3. inner scroll을 less 스크롤
            // inner scroll을 모두 less scroll한 경우, outer scroll을 less scroll
            if innerScroll && lessScroll {
                print("3")
                defer { innerScrollView.lastOffsetY = innerScrollView.contentOffset.y }
                guard innerScrollView.contentOffset.y < 0 && outerScrollView.contentOffset.y > 0 else { return }
                
                // innerScrollView의 bounces에 의하여 다시 outerScrollView가 당겨질수 있으므로 bounces로 다시 되돌아가는 offset 방지
                guard innerScrollView.lastOffsetY > innerScrollView.contentOffset.y else { return }
                
                let moveOffset = outerScrollMaxOffsetY - abs(innerScrollView.contentOffset.y) * 3
                guard moveOffset < outerScrollView.contentOffset.y else { return }
                
                outerScrollView.contentOffset.y = max(moveOffset, 0)
            }
            
            // 4. inner scroll을 more 스크롤
            // outer scroll이 아직 more 스크롤할게 남아 있다면, innerScroll을 그대로 두고 outer scroll을 more 스크롤
            if innerScroll && moreScroll {
                print("4")
                guard
                    outerScrollView.contentOffset.y + Policy.floatingPointTolerance < outerScrollMaxOffsetY,
                    !innerScrollingDownDueToOuterScroll
                else { return }
                // outer scroll를 more 스크롤
                let minOffetY = min(outerScrollView.contentOffset.y + innerScrollView.contentOffset.y, outerScrollMaxOffsetY)
                let offsetY = max(minOffetY, 0)
                outerScrollView.contentOffset.y = offsetY
                
                // inner scroll은 스크롤 되지 않아야 하므로 0으로 고정
                innerScrollView.contentOffset.y = 0
            }
            
        }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.horizontalScrollView {
            headerTabView.titleButtonList.forEach {
                $0.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
            }
            let index = (Int)(scrollView.contentOffset.x/self.view.frame.width)
            headerTabView.titleButtonList[index].setTitleColor(UIColor(hex: 0x6F81A9), for: .normal)
            
            switch index {
            case 0:
                innerScrollView = noticeCollectionView
            case 1:
                innerScrollView = calendarCollectionView
            default:
                return
            }
        }

    }
}

extension JoinedGroupDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let viewModel else { return CGSize() }
        let item = indexPath.item
        
        let maxItem = ((item-item%7)..<(item+7-item%7)).max(by: { (a,b) in
            viewModel.mainDayList[a].todoList?.count ?? 0 < viewModel.mainDayList[b].todoList?.count ?? 0
        }) ?? Int()
        
        let maxTodoViewModel = viewModel.mainDayList[maxItem]
        
        let frameSize = self.view.frame
        
        var todoCount = maxTodoViewModel.todoList?.count ?? 0
        
        if let height = viewModel.cachedCellHeightForTodoCount[todoCount] {
            return CGSize(width: Double(1)/Double(7) * Double(frameSize.width), height: Double(height))
            
        } else {
            let mockCell = DailyCalendarCell(mockFrame: CGRect(x: 0, y: 0, width: Double(1)/Double(7) * frameSize.width, height: 116))
            mockCell.fill(todoList: maxTodoViewModel.todoList)

            mockCell.layoutIfNeeded()
            
            let estimatedSize = mockCell.systemLayoutSizeFitting(CGSize(width: Double(1)/Double(7) * frameSize.width, height: 116))
            viewModel.cachedCellHeightForTodoCount[todoCount] = estimatedSize.height
            
            return CGSize(width: Double(1)/Double(7) * frameSize.width, height: estimatedSize.height)
        }
    }
}

extension JoinedGroupDetailViewController: JoinedGroupNoticeDataSourceDelegate {
    func memberCount() -> Int? {
        return viewModel?.memberList?.count
    }
    
    func memberInfo(index: Int) -> Member? {
        return viewModel?.memberList?[index]
    }
    
    func notice() -> String? {
        return viewModel?.notice
    }
    
    func isNoticeFetched() -> Bool {
        return (viewModel?.notice == nil) ? false : true
    }
}

// 헤더에 날짜, 요일 등의 정보를 올리자..!
class CalendarDataSource: NSObject, UICollectionViewDataSource {
    weak var delegate: CalendarDataSourceDelegate?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.dayCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCell.identifier, for: indexPath) as? DailyCalendarCell,
              let dayViewModel = delegate?.dayViewModel(index: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        cell.fill(day: "\(Calendar.current.component(.day, from: dayViewModel.date))", state: dayViewModel.state, weekDay: WeekDay(rawValue: (Calendar.current.component(.weekday, from: dayViewModel.date)+5)%7)!, todoList: dayViewModel.todoList)

        return cell
    }
}

protocol CalendarDataSourceDelegate: NSObject {
    func dayCount() -> Int?
    func dayViewModel(index: Int) -> DayViewModel?
}

extension JoinedGroupDetailViewController: CalendarDataSourceDelegate {
    func dayCount() -> Int? {
        viewModel?.mainDayList.count ?? 0
    }
    
    func dayViewModel(index: Int) -> DayViewModel? {
        viewModel?.mainDayList[index] ?? nil
    }
}


// MARK: Notice Tab collectionview layout
extension JoinedGroupDetailViewController {
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

// MARK: Calendar Tab Layout




private struct AssociatedKeys {
    static var lastOffsetY = "lastOffsetY"
}

extension UIScrollView {
    var lastOffsetY: CGFloat {
        get {
            (objc_getAssociatedObject(self, &AssociatedKeys.lastOffsetY) as? CGFloat) ?? contentOffset.y
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lastOffsetY, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

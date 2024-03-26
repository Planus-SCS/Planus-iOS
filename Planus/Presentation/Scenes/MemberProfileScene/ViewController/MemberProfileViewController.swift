//
//  MemberProfileViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift
import RxCocoa

final class MemberProfileViewController: UIViewController {
    private var bag = DisposeBag()
    private var viewModel: MemberProfileViewModel?
    
    private var headerViewInitialHeight: CGFloat?
    private let headerViewFinalHeight: CGFloat? = 98
    
    private var dragInitialY: CGFloat = 0
    private var dragPreviousY: CGFloat = 0
    private var dragDirection: DragDirection = .Up

    private var headerViewHeightConstraint: NSLayoutConstraint?
    
    private var isSingleSelected = PublishRelay<IndexPath>()
    private var indexChanged = PublishRelay<Int>()
    private var isMonthChanged = PublishRelay<Date>()
    private var didInitialCalendarGenerated = false
    
    private let headerView = MemberProfileHeaderView(frame: .zero)
    private let calendarHeaderView = MemberProfileCalendarHeaderView(frame: .zero)
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true
        collectionView.register(MemberMonthlyCalendarCell.self, forCellWithReuseIdentifier: MemberMonthlyCalendarCell.reuseIdentifier)
        
        return collectionView
    }()
    
    private lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .black
        return item
    }()
    
    convenience init(viewModel: MemberProfileViewModel) {
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
        configurePanGesture()
        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "그룹 멤버 캘린더"
        self.navigationItem.setLeftBarButton(backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            viewModel?.actions.finishScene?()
        }
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = MemberProfileViewModel.Input(
            indexChanged: indexChanged.asObservable(),
            viewDidLoaded: Observable.just(()),
            didSelectItem: isSingleSelected.asObservable(),
            didTappedTitleButton: calendarHeaderView.yearMonthButton.rx.tap.asObservable(),
            didSelectMonth: isMonthChanged.asObservable(),
            backBtnTapped: backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.didLoadYYYYMM
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, text in
                vc.calendarHeaderView.yearMonthButton.setTitle(text, for: .normal)
            }
            .disposed(by: bag)
        
        output.initialDayListFetchedInCenterIndex
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, center in
                vc.collectionView.performBatchUpdates({
                    vc.collectionView.reloadData()
                }, completion: { _ in
                    vc.collectionView.contentOffset = CGPoint(x: CGFloat(center) * vc.view.frame.width, y: 0)
                    vc.didInitialCalendarGenerated = true
                })
            })
            .disposed(by: bag)
            
        output.needReloadSectionInRange
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, rangeSet in
                vc.collectionView.reloadSections(rangeSet)
            })
            .disposed(by: bag)
        
        output.showMonthPicker
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] first, current, last in
                self?.showMonthPicker(first: first, current: current, last: last)
            })
            .disposed(by: bag)
        
        output.monthChangedByPicker
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.collectionView.setContentOffset(CGPoint(x: Double(index)*vc.view.frame.width, y: 0), animated: false)
            })
            .disposed(by: bag)
        
        output
            .memberImage
            .compactMap { $0 }
            .map { UIImage(data: $0) }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: headerView.profileImageView.rx.image)
            .disposed(by: bag)
        
        headerView.nameLabel.text = output.memberName
        headerView.introduceLabel.text = output.memberDesc
                
        configureHeaderViewLayout(
            memberName: output.memberName,
            memberDesc: output.memberDesc
        )
    }
    
    func configureHeaderViewLayout(memberName: String?, memberDesc: String?) {
        let mockView = MemberProfileHeaderView(
            mockName: memberName,
            mockDesc: memberDesc
        )
        let estimatedSize = mockView
            .systemLayoutSizeFitting(CGSize(width: self.view.frame.width,
                                            height: 111))

        self.headerViewInitialHeight = estimatedSize.height
        
        headerView.snp.makeConstraints {
            $0.height.equalTo(estimatedSize.height)
        }
        
        guard let headerViewHeightConstraint = headerView.constraints.first(where: { $0.firstAttribute == .height }) else { return }
        self.headerViewHeightConstraint = headerViewHeightConstraint
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)

        self.view.addSubview(headerView)
        self.view.addSubview(calendarHeaderView)
        self.view.addSubview(collectionView)
    }
    
    func configureLayout() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        calendarHeaderView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(83)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(calendarHeaderView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configurePanGesture() {
        let topViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))

        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(topViewPanGesture)
    }
}

extension MemberProfileViewController {
    func showMonthPicker(first: Date, current: Date, last: Date) {
        let vc = MonthPickerViewController(firstYear: first, lastYear: last, currentDate: current) { [weak self] date in
            self?.isMonthChanged.accept(date)
        }

        vc.preferredContentSize = CGSize(width: 320, height: 290)
        vc.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view

        let globalFrame = self.calendarHeaderView.yearMonthButton.convert(self.calendarHeaderView.yearMonthButton.bounds, to: self.view)
        popover.sourceRect = CGRect(x: globalFrame.midX, y: globalFrame.maxY, width: 0, height: 0)
        popover.permittedArrowDirections = [.up]
        self.present(vc, animated: true, completion: nil)
        print(globalFrame)
    }
}



extension MemberProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.mainDays.count ?? Int()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemberMonthlyCalendarCell.reuseIdentifier, for: indexPath) as? MemberMonthlyCalendarCell,
            let viewModel else { return UICollectionViewCell() }
        
        cell.fill(
            section: indexPath.section,
            viewModel: viewModel
        )
        cell.fill(
            isSingleSelected: isSingleSelected
        )
        
        cell.fill(
            headerInitialHeight: headerViewInitialHeight,
            headerFinalHeight: headerViewFinalHeight
        )
        cell.nestedScrollableCellDelegate = self
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let floatedIndex = scrollView.contentOffset.x/scrollView.bounds.width
        guard !(floatedIndex.isNaN || floatedIndex.isInfinite) && didInitialCalendarGenerated else { return }
        indexChanged.accept(Int(round(floatedIndex)))
    }
    
    
}

extension MemberProfileViewController {

    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
    
}

extension MemberProfileViewController {
    @objc 
    func topViewMoved(_ gesture: UIPanGestureRecognizer) {
        
        var dragYDiff : CGFloat

        switch gesture.state {
            
        case .began:
            
            dragInitialY = gesture.location(in: self.view).y
            dragPreviousY = dragInitialY
            
        case .changed:
            
            let dragCurrentY = gesture.location(in: self.view).y
            dragYDiff = dragPreviousY - dragCurrentY
            dragPreviousY = dragCurrentY
            dragDirection = dragYDiff < 0 ? .Down : .Up
            innerTableViewDidScroll(withDistance: dragYDiff)
            
        case .ended:
            innerTableViewScrollEnded(withScrollDirection: dragDirection)
            return
        default: return
        
        }
    }
}

extension MemberProfileViewController: NestedScrollableCellDelegate {
    
    var currentHeaderHeight: CGFloat? {
        return headerViewHeightConstraint?.constant
    }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        guard let headerViewHeightConstraint else { return }
        headerViewHeightConstraint.constant -= scrollDistance

        if headerViewHeightConstraint.constant < headerViewFinalHeight ?? 0 {
            headerViewHeightConstraint.constant = headerViewFinalHeight ?? 0
        } else if headerViewHeightConstraint.constant >= headerViewInitialHeight ?? 0 {
            headerViewHeightConstraint.constant = headerViewInitialHeight ?? 0
        }
    }

    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection) {
        guard let headerViewHeightConstraint else { return }

        let topViewHeight = headerViewHeightConstraint.constant

        if topViewHeight >= headerViewInitialHeight ?? 0 {
            scrollToInitialView()
        }
    }

    func scrollToInitialView() {
        guard let headerViewHeightConstraint else { return }

        let topViewCurrentHeight = headerView.frame.height

        let distanceToBeMoved = abs(topViewCurrentHeight - (headerViewInitialHeight ?? 0))

        var time = distanceToBeMoved / 500

        if time < 0.2 {

            time = 0.2
        }

        headerViewHeightConstraint.constant = headerViewInitialHeight ?? 0

        UIView.animate(withDuration: TimeInterval(time), animations: {

            self.view.layoutIfNeeded()
        })
    }

    func scrollToFinalView() {
        guard let headerViewHeightConstraint else { return }

        let topViewCurrentHeight = headerView.frame.height

        let distanceToBeMoved = abs(topViewCurrentHeight - (headerViewFinalHeight ?? 0))

        var time = distanceToBeMoved / 500

        if time < 0.2 {

            time = 0.2
        }

        headerViewHeightConstraint.constant = headerViewFinalHeight ?? 0

        UIView.animate(withDuration: TimeInterval(time), animations: {

            self.view.layoutIfNeeded()
        })
    }
}


extension MemberProfileViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension MemberProfileViewController: UIGestureRecognizerDelegate {}

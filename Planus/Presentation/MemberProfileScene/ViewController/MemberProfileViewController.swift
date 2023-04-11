//
//  MemberProfileViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift

class MemberProfileViewController: UIViewController {
    var bag = DisposeBag()
    var viewModel: MemberProfileViewModel?
    
    var headerViewHeightConstraint: NSLayoutConstraint?
    
    var isSingleSelected = PublishSubject<IndexPath>()
    var scrolledTo = PublishSubject<ScrollDirection>()
    var isMonthChanged = PublishSubject<Date>()
    
    let headerView = MemberProfileHeaderView(frame: .zero)
    let calendarHeaderView = MemberProfileCalendarHeaderView(frame: .zero)
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true
        collectionView.register(NestedScrollableMonthlyCalendarCell.self, forCellWithReuseIdentifier: NestedScrollableMonthlyCalendarCell.reuseIdentifier)
        
        return collectionView
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    @objc func backBtnAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
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
        
        self.navigationItem.setLeftBarButton(backButton, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "그룹 멤버 캘린더"
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = MemberProfileViewModel.Input(
            didScrollTo: self.scrolledTo.asObservable(),
            viewDidLoaded: Observable.just(()),
            didSelectItem: isSingleSelected.asObservable(),
            didTappedTitleButton: calendarHeaderView.yearMonthButton.rx.tap.asObservable(),
            didSelectMonth: isMonthChanged.asObservable()
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
                vc.collectionView.reloadData()
                vc.collectionView.contentOffset = CGPoint(x: CGFloat(center) * vc.view.frame.width, y: 0)
            })
            .disposed(by: bag)
            
        output.todoListFetchedInIndexRange
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, rangeSet in
                vc.collectionView.reloadSections(IndexSet(rangeSet.0..<rangeSet.1))
            })
            .disposed(by: bag)
        
        output.showDailyTodoPage
            .withUnretained(self)
            .subscribe(onNext: { vc, date in
                guard let minDate = vc.viewModel?.mainDayList.first?.first?.date,
                      let maxDate = vc.viewModel?.mainDayList.last?.last?.date else {
                    return
                }
                let fetchTodoListUseCase = DefaultReadTodoListUseCase(todoRepository: TestTodoRepository())
                let viewModel = TodoDailyViewModel(fetchTodoListUseCase: fetchTodoListUseCase)
                viewModel.setDate(currentDate: date, min: minDate, max: maxDate)

                let viewController = TodoDailyViewController(viewModel: viewModel)
                let nav = UINavigationController(rootViewController: viewController)
                nav.modalPresentationStyle = .pageSheet
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                }
                vc.present(nav, animated: true)
            })
            .disposed(by: bag)
        
        output.showMonthPicker
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { first, current, last in
                let vc = MonthPickerViewController(firstYear: first, lastYear: last, currentDate: current) { [weak self] date in
                    self?.isMonthChanged.onNext(date)
                }
                // 여기서 앞뒤로 범위까지 전달할 수 있어야함. 즉, 저걸 열면 현재날짜에서 월별로 앞뒤로를 만들어서 한번에 데이터소스에 집어넣는게 맞을듯하다..!아이구야,,,
                vc.preferredContentSize = CGSize(width: 320, height: 290)
                vc.modalPresentationStyle = .popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.delegate = self
                popover.sourceView = self.view
                popover.sourceItem = self.calendarHeaderView.yearMonthButton
                
                self.present(vc, animated: true, completion:nil)
            })
            .disposed(by: bag)
        
        output.monthChangedByPicker
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.collectionView.setContentOffset(CGPoint(x: Double(index)*vc.view.frame.width, y: 0), animated: false)
            })
            .disposed(by: bag)
        
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
            $0.height.equalTo(208)
        }
        
        guard let headerViewHeightConstraint = headerView.constraints.first(where: { $0.firstAttribute == .height }) else { return }
        self.headerViewHeightConstraint = headerViewHeightConstraint
        
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
    
    var dragInitialY: CGFloat = 0
    var dragPreviousY: CGFloat = 0
    var dragDirection: DragDirection = .Up
    
    @objc func topViewMoved(_ gesture: UIPanGestureRecognizer) {
        
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
            return
            innerTableViewScrollEnded(withScrollDirection: dragDirection)
            
        default: return
        
        }
    }
    
}



extension MemberProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.mainDayList.count ?? Int()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NestedScrollableMonthlyCalendarCell.reuseIdentifier, for: indexPath) as? NestedScrollableMonthlyCalendarCell,
            let viewModel else { return UICollectionViewCell() }
        
        cell.fill(
            section: indexPath.section,
            delegate: self,
            nestedScrollableCellDelegate: self
        )

        cell.fill(
            isSingleSelected: isSingleSelected
        )
        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x > 0 {
            scrolledTo.onNext(.right)
        } else if velocity.x < 0 {
            scrolledTo.onNext(.left)
        }
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
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
    
}

extension MemberProfileViewController: NestedScrollableMonthlyCalendarCellDelegate {

    func monthlyCalendarCell(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell, at indexPath: IndexPath) -> DayViewModel? {
        guard let viewModel else { return nil }
        return viewModel.mainDayList[indexPath.section][indexPath.item]
    }
    
    func monthlyCalendarCell(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell, maxCountOfTodoInWeek indexPath: IndexPath) -> DayViewModel? {
        guard let viewModel else { return nil }
        let item = indexPath.item
        let maxItem = ((item-item%7)..<(item+7-item%7)).max(by: { (a,b) in
            viewModel.mainDayList[indexPath.section][a].todoList?.count ?? 0 < viewModel.mainDayList[indexPath.section][b].todoList?.count ?? 0
        }) ?? Int()
            
        return viewModel.mainDayList[indexPath.section][maxItem]
    }
    
    func numberOfItems(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell, in section: Int) -> Int? {
        return viewModel?.mainDayList[section].count
    }
    
    func findCachedHeight(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell, todoCount: Int) -> Double? {
        return viewModel?.cachedCellHeightForTodoCount[todoCount]
    }
    
    func cacheHeight(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell, count: Int, height: Double) {
        viewModel?.cachedCellHeightForTodoCount[count] = height
    }
    
    func frameWidth(_ monthlyCalendarCell: NestedScrollableMonthlyCalendarCell) -> CGSize {
        return self.view.frame.size
    }
    
}


extension MemberProfileViewController: NestedScrollableCellDelegate {
    
    var currentHeaderHeight: CGFloat? {
        return headerViewHeightConstraint?.constant
    }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        guard let headerViewHeightConstraint else { return }
        headerViewHeightConstraint.constant -= scrollDistance

        if headerViewHeightConstraint.constant < memberProfileTopViewFinalHeight {
            headerViewHeightConstraint.constant = memberProfileTopViewFinalHeight
        } else if headerViewHeightConstraint.constant >= memberProfileTopViewInitialHeight {
            headerViewHeightConstraint.constant = memberProfileTopViewInitialHeight
        }
    }
//
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection) {
        guard let headerViewHeightConstraint else { return }

        let topViewHeight = headerViewHeightConstraint.constant

        if topViewHeight >= memberProfileTopViewInitialHeight {
            scrollToInitialView()
        }
    }

    func scrollToInitialView() {
        guard let headerViewHeightConstraint else { return }

        let topViewCurrentHeight = headerView.frame.height

        let distanceToBeMoved = abs(topViewCurrentHeight - memberProfileTopViewInitialHeight)

        var time = distanceToBeMoved / 500

        if time < 0.2 {

            time = 0.2
        }

        headerViewHeightConstraint.constant = memberProfileTopViewInitialHeight

        UIView.animate(withDuration: TimeInterval(time), animations: {

            self.view.layoutIfNeeded()
        })
    }

    func scrollToFinalView() {
        guard let headerViewHeightConstraint else { return }

        let topViewCurrentHeight = headerView.frame.height

        let distanceToBeMoved = abs(topViewCurrentHeight - memberProfileTopViewFinalHeight)

        var time = distanceToBeMoved / 500

        if time < 0.2 {

            time = 0.2
        }

        headerViewHeightConstraint.constant = memberProfileTopViewFinalHeight

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

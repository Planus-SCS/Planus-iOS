//
//  HomeCalendarViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit
import RxSwift

class HomeCalendarViewController: UIViewController {
    
    var bag = DisposeBag()
    
    var viewModel: HomeCalendarViewModel?
    
    var selectionState: Bool = false
    
    var firstPressedIndexPath: IndexPath? //드래그한놈들을 전부 유지하고 다시그리게 해야하나?
    var lastPressedIndexPath: IndexPath?
    
    let scrollDidDeceleratedWithDoubleIndex = PublishSubject<Double>()
    
    lazy var yearMonthButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("2020년 0월", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.setImage(UIImage(named: "downButton"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: -5)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(yearMonthButtonTapped), for: .touchUpInside)

        return button
    }()
    
    @objc func yearMonthButtonTapped(_ sender: UIButton) {
//        let vc = MonthPickerController(year: 2023, month: 3)
//        // Preferred Size
//        vc.preferredContentSize = CGSize(width: 320, height: 290)
//        vc.modalPresentationStyle = .popover
//        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = self.view
//        popover.sourceItem = yearMonthButton
//
//        present(vc, animated: true, completion:nil)
    }
    
    var groupListButton: UIBarButtonItem = {
        let image = UIImage(named: "groupCalendarList")
        
        let all = UIAction(title: "모아 보기", handler: { _ in print("전체 캘린더 조회") })
        let groupA = UIAction(title: "ios 스터디", handler: { _ in print("스터디 캘린더 조회") })
        
        let buttonMenu = UIMenu(options: .displayInline, children: [all, groupA])
        
        let item = UIBarButtonItem(image: image, menu: buttonMenu)
        item.tintColor = UIColor(hex: 0x000000)
        return item
    }()
    
    lazy var profileButton: UIBarButtonItem = {
        let image = UIImage(named: "userDefaultIconSmall")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(profileButtonTapped))
        
        item.tintColor = UIColor(hex: 0x000000)
        return item
    }()
    
    var todayButton = UIButton()
    var weekStackView = UIStackView()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true
        collectionView.register(MonthlyCalendarCell.self, forCellWithReuseIdentifier: MonthlyCalendarCell.reuseIdentifier)
        
        return collectionView
    }()
        
//    lazy var lpgr : UILongPressGestureRecognizer = {
//        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
//        lpgr.minimumPressDuration = 0.5
//        lpgr.delegate = self
//        lpgr.delaysTouchesBegan = true
//        return lpgr
//    }()
//
//    lazy var pgr: UIPanGestureRecognizer = {
//        let pgr = UIPanGestureRecognizer(target: self, action: #selector(self.drag(_:)))
//        pgr.delegate = self
//        return pgr
//    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: HomeCalendarViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        bind()
        configureView()
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.titleView = yearMonthButton
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = HomeCalendarViewModel.Input(
            scrollDidDeceleratedWithDoubleIndex: self.scrollDidDeceleratedWithDoubleIndex.asObservable(),
            viewDidLoaded: Observable.just(())
        )
        
        let output = viewModel.transform(input: input)
        
        output.didLoadYearMonth
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] text in
                self?.yearMonthButton.setTitle(text, for: .normal)
            }
            .disposed(by: bag)
        
        output.initDaysLoaded
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .subscribe { [weak self] count in
                guard let self,
                      let viewModel = self.viewModel else { return }
                self.collectionView.reloadData()
                self.collectionView.contentOffset = CGPoint(x: CGFloat(count/2)*self.view.frame.width, y: 0)
//                var snapshot = NSDiffableDataSourceSnapshot<Int, DayViewModel>()
//                snapshot.appendSections(Array(0..<viewModel.days.count))
//                viewModel.days.enumerated().forEach { index, item in
//                    snapshot.appendItems(item, toSection: index)
//                }
//                self.dataSource.apply(snapshot, completion: {
//                    self.collectionView.contentOffset = CGPoint(x: CGFloat(count/2)*self.view.frame.width, y: 0)
//                })
            }
            .disposed(by: bag)
        
        output.nowLoading
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] in
            }
            .disposed(by: bag)
//
        output.prevDaysLoaded
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] count in
                let exOffset = self!.collectionView.contentOffset
                self?.collectionView.reloadData()
                self?.collectionView.contentOffset = CGPoint(x: exOffset.x + CGFloat(count)*self!.view.frame.width, y: 0)

            }
            .disposed(by: bag)
        
        output.followingDaysLoaded
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] count in
                guard let exCount = self?.viewModel?.days.count else { return }

                let exOffset = self!.collectionView.contentOffset

                self?.collectionView.reloadData()
                self?.collectionView.contentOffset = CGPoint(x: exOffset.x - CGFloat(count)*self!.view.frame.width, y: 0)
            }
            .disposed(by: bag)
    }
    
//    func configureGestureRecognizer() {
//        self.collectionView.addGestureRecognizer(lpgr)
//        self.collectionView.addGestureRecognizer(pgr)
//    }
    
    var dataSource: UICollectionViewDiffableDataSource<Int, DayViewModel>!
    
//    func configureSource() {
//        let imageCellRegistration = UICollectionView.CellRegistration<CustomCell, DayViewModel> { (cell, indexPath, dayViewModel) in
//            cell.fill(day: "\(Calendar.current.component(.day, from: dayViewModel.date))", state: dayViewModel.state, weekDay: WeekDay(rawValue: Calendar.current.component(.weekday, from: dayViewModel.date) - 1)!, todoList: self.viewModel!.todoContainer.todoList(of: dayViewModel.date))
//            cell.fill(dummy: (self.viewModel!.maxTodoInWeek(section: indexPath.section, item: indexPath.row) ?? Int()) - (self.viewModel!.todoContainer.todoList(of: dayViewModel.date).count))
//            if dayViewModel.date == self.viewModel?.today {
//                cell.backgroundColor = .white
//                cell.layer.cornerRadius = 3
//                cell.layer.cornerCurve = .continuous
//            } else {
//                cell.backgroundColor = nil
//                cell.layer.cornerRadius = 3
//                cell.layer.cornerCurve = .continuous
//            }
//        }
//
//        // MARK: DataSoucre Cell Provider
//        dataSource = UICollectionViewDiffableDataSource<Int, DayViewModel>(collectionView: collectionView) { collectionView, indexPath, item in
//            return collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: item)
//        }
//
//                // 초기 데이터 셋팅(섹션 셋팅)
//        var snapshot = NSDiffableDataSourceSnapshot<Int, DayViewModel>()
//        snapshot.appendSections([])
//        self.dataSource.apply(snapshot, animatingDifferences: false)
//
//    }
//
//    var a = ["월","화", "수", "목", "금", "토", "일"]
    
    var isSelecting = PublishSubject<Bool>()
}

extension HomeCalendarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension HomeCalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.days.count ?? Int()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell,
//              let dayViewModel = viewModel?.days[indexPath.section][indexPath.item] else {
//            return UICollectionViewCell()
//        }
//        // 안쪽의 데이터소스한테 그대~로 전달해야함!
//        cell.fill(day: "\(Calendar.current.component(.day, from: dayViewModel.date))", state: dayViewModel.state, weekDay: WeekDay(rawValue: Calendar.current.component(.weekday, from: dayViewModel.date) - 1)!, todoList: viewModel!.todoContainer.todoList(of: dayViewModel.date))
//        if dayViewModel.date == viewModel?.today {
//            cell.backgroundColor = .white
//            cell.layer.cornerRadius = 3
//            cell.layer.cornerCurve = .continuous
//        } else {
//            cell.backgroundColor = nil
//            cell.layer.cornerRadius = 3
//            cell.layer.cornerCurve = .continuous
//        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthlyCalendarCell.reuseIdentifier, for: indexPath) as? MonthlyCalendarCell,
            let viewModel else { return UICollectionViewCell() }
        
        cell.fill(dayViewModelList: viewModel.days[indexPath.section])
        cell.fill(isMultipleSelecting: self.isSelecting)
        let bag = DisposeBag()
        
        isSelecting
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { bool in
                self.collectionView.isScrollEnabled = !bool
                self.collectionView.isUserInteractionEnabled = !bool
            })
            .disposed(by: bag)
        
        cell.bag = bag
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let vc = ViewController2(nibName: nil, bundle: nil)
//        vc.closure1 = { (category: TodoCategory) in
//            guard let paths = self.collectionView.indexPathsForSelectedItems else { return }
//            paths.forEach { indexPath in
//                let viewModel = self.viewModel!.days[indexPath.section][indexPath.item]
//                let todo = Todo(title: "test", date: viewModel.date, category: category, type: .normal)
//                self.viewModel?.todoContainer.append(item: todo, date: viewModel.date)
////                self.viewModel?.days[indexPath.section][indexPath.item].todo.append(todo)
//            }
//
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//        }
//
//        vc.closure2 = { () in
//            guard let paths = self.collectionView.indexPathsForSelectedItems else { return }
//            paths.forEach { indexPath in
//                self.collectionView.deselectItem(at: indexPath, animated: true)
//            }
//        }
//
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .pageSheet
//        if let sheet = nav.sheetPresentationController {
//            sheet.detents = [.large()]
//        }
//        self.navigationController?.topViewController?.present(nav, animated: true)
//    }
    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if decelerate {
//            DispatchQueue.main.async {
////                scrollView.isUserInteractionEnabled = false
//            }
//        }
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        self.scrollDidDeceleratedWithDoubleIndex.onNext(scrollView.contentOffset.x/self.view.frame.width)
//        DispatchQueue.main.async {
////            scrollView.isUserInteractionEnabled = true
//        }
//    }
//
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.scrollDidDeceleratedWithDoubleIndex.onNext(scrollView.contentOffset.x/self.view.frame.width)
//    }
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if velocity.x > 0 {
//            scrollDidDeceleratedWithDoubleIndex.onNext(.next)
//        } else if velocity.x < 0 {
//            scrollDidDeceleratedWithDoubleIndex.onNext(.prev)
//        }
//    }
    
}

// MARK: configureVC

extension HomeCalendarViewController {
    
    func configureLayout() {
        weekStackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(25)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(weekStackView.snp.bottom).offset(10)
            $0.leading.equalTo(weekStackView.snp.leading)
            $0.trailing.equalTo(weekStackView.snp.trailing)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        yearMonthButton.snp.makeConstraints {
            $0.width.equalTo(150)
            $0.height.equalTo(50)
        }
    }
    
    @objc func profileButtonTapped() {
        print("to profile")
    }

    func configureView() {
        self.navigationItem.setLeftBarButton(groupListButton, animated: false)
        self.navigationItem.setRightBarButton(profileButton, animated: false)

        self.view.addSubview(weekStackView)
        weekStackView.distribution = .fillEqually

        let dayOfTheWeek = ["월", "화", "수", "목", "금", "토", "일"]
        for i in 0..<7 {
            let label = UILabel()
            label.text = dayOfTheWeek[i]
            label.textAlignment = .center
            label.font = UIFont(name: "Pretendard-Regular", size: 12)
            self.weekStackView.addArrangedSubview(label)
        }
        self.view.addSubview(collectionView)
    }
}


//// MARK: gesture actions
//
//extension HomeCalendarViewController {
//    @objc func longTap(_ gestureRecognizer: UILongPressGestureRecognizer){
//        if gestureRecognizer.state == .began {
//            let location = gestureRecognizer.location(in: collectionView)
//            guard let nowIndexPath = collectionView.indexPathForItem(at: location) else { return }
//
//            selectionState = true
//
//            self.firstPressedIndexPath = nowIndexPath
//            self.lastPressedIndexPath = nowIndexPath
//
//            collectionView.selectItem(at: nowIndexPath, animated: true, scrollPosition: [])
//        }
//    }
//
//    @objc func drag(_ gestureRecognizer: UIPanGestureRecognizer) {
//        guard self.selectionState else {
//            collectionView.isScrollEnabled = true
//            collectionView.isUserInteractionEnabled = true
//            return
//        }
//        let location = gestureRecognizer.location(in: collectionView)
//
//        guard let nowIndexPath = collectionView.indexPathForItem(at: location) else { return }
//        switch gestureRecognizer.state {
//        case .began:
//            collectionView.isScrollEnabled = false
//            collectionView.isUserInteractionEnabled = false
//            collectionView.allowsMultipleSelection = true
//        case .changed:
//            guard let firstPressedIndexPath = firstPressedIndexPath,
//                  let lastPressedIndexPath = lastPressedIndexPath,
//                  nowIndexPath != lastPressedIndexPath else { return }
//            print(firstPressedIndexPath.item, lastPressedIndexPath.item, nowIndexPath.item)
//
//            if firstPressedIndexPath.item < lastPressedIndexPath.item {
//                if firstPressedIndexPath.item > nowIndexPath.item {
//                    (firstPressedIndexPath.item+1...lastPressedIndexPath.item).forEach {
//                        self.collectionView.deselectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true)
//                    }
//                    (nowIndexPath.item..<firstPressedIndexPath.item).forEach {
//                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
//                    }
//                } else if nowIndexPath.item < lastPressedIndexPath.item {
//                    (nowIndexPath.item+1...lastPressedIndexPath.item).forEach {
//                        self.collectionView.deselectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true)
//                    }
//                } else if nowIndexPath.item > lastPressedIndexPath.item {
//                    (lastPressedIndexPath.item+1...nowIndexPath.item).forEach {
//                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
//                    }
//                }
//            } else if (firstPressedIndexPath.item > lastPressedIndexPath.item) {
//                if (firstPressedIndexPath.item < nowIndexPath.item) {
//
//                    (lastPressedIndexPath.item..<firstPressedIndexPath.item).forEach {
//                        self.collectionView.deselectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true)
//                    }
//                    (firstPressedIndexPath.item+1...nowIndexPath.item).forEach {
//                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
//                    }
//                } else if lastPressedIndexPath.item < nowIndexPath.item {
//
//                    (lastPressedIndexPath.item..<nowIndexPath.item).forEach {
//                        self.collectionView.deselectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true)
//                    }
//                } else if nowIndexPath.item < lastPressedIndexPath.item {
//
//                    (nowIndexPath.item..<lastPressedIndexPath.item).forEach {
//                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
//                    }
//                }
//            } else {
//                if nowIndexPath.item > lastPressedIndexPath.item {
//
//                    (lastPressedIndexPath.item+1...nowIndexPath.item).forEach {
//                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
//                    }
//                } else {
//
//                    (nowIndexPath.item..<lastPressedIndexPath.item).forEach {
//                        self.collectionView.selectItem(at: IndexPath(item: $0, section: firstPressedIndexPath.section), animated: true, scrollPosition: [])
//                    }
//                }
//            }
//
//            self.lastPressedIndexPath = nowIndexPath
//        case .ended:
//            selectionState = false
//
//            firstPressedIndexPath = nil
//            lastPressedIndexPath = nil
//
//            collectionView.isScrollEnabled = true
//            collectionView.isUserInteractionEnabled = true
//            collectionView.allowsMultipleSelection = false
//
//            let vc = ViewController2(nibName: nil, bundle: nil)
//            vc.closure1 = { (category: TodoCategory) in
//                guard let paths = self.collectionView.indexPathsForSelectedItems else { return }
//
//                paths.forEach { indexPath in
//                    let viewModel = self.viewModel!.days[indexPath.section][indexPath.item]
//                    let todo = Todo(title: "test", date: viewModel.date, category: category, type: .normal)
//                    self.viewModel?.todoContainer.append(item: todo, date: viewModel.date)
////                    self.viewModel?.days[indexPath.section][indexPath.item].todo.append(todo)
//                }
//
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//            }
//
//            vc.closure2 = { () in
//                guard let paths = self.collectionView.indexPathsForSelectedItems else { return }
//                paths.forEach { indexPath in
//                    self.collectionView.deselectItem(at: indexPath, animated: true)
//                }
//            }
//
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .pageSheet
//            if let sheet = nav.sheetPresentationController {
//                sheet.detents = [.medium()]
//            }
//            self.navigationController?.topViewController?.present(nav, animated: true)
//        default:
//            print(gestureRecognizer.state)
//        }
//
//
//    }
//}

// MARK: GestureRecognizerDelegate

//extension HomeCalendarViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}

// MARK: Compositional layout

extension HomeCalendarViewController {

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

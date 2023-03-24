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
    
    var isSelecting = PublishSubject<Bool>()
    
    let scrolledTo = PublishSubject<ScrollDirection>()
    
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
            didScrollTo: self.scrolledTo.asObservable(),
            viewDidLoaded: Observable.just(())
        )
        
        let output = viewModel.transform(input: input)
        
        output.didLoadYYYYMM
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] text in
                self?.yearMonthButton.setTitle(text, for: .normal)
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

    }
    
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
}

extension HomeCalendarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension HomeCalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.mainDayList.count ?? Int()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthlyCalendarCell.reuseIdentifier, for: indexPath) as? MonthlyCalendarCell,
            let viewModel else { return UICollectionViewCell() }
        
        cell.fill(dayViewModelList: viewModel.mainDayList[indexPath.section])
        cell.fill(isMultipleSelecting: self.isSelecting) // 이거랑 어디부터 어디까지 드래그하고있는지도 보내야함!
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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x > 0 {
            scrolledTo.onNext(.right)
        } else if velocity.x < 0 {
            scrolledTo.onNext(.left)
        }
    }
    
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

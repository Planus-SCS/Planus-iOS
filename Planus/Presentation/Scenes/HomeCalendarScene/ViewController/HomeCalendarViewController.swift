//
//  HomeCalendarViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeCalendarView: UIView {
    lazy var yearMonthButton: SpringableButton = {
        let button = SpringableButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.setImage(UIImage(named: "downButton"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: -5)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)

        return button
    }()
    
    var groupListButton: UIBarButtonItem? // 그룹 로드 후 생성
    
    lazy var profileButton: ProfileButton = {
        let button = ProfileButton(frame: .zero)
        return button
    }()
    
    var weekStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.distribution = .fillEqually

        let dayOfTheWeek = ["월", "화", "수", "목", "금", "토", "일"]
        for i in 0..<7 {
            let label = UILabel()
            label.text = dayOfTheWeek[i]
            label.textAlignment = .center
            label.font = UIFont(name: "Pretendard-Regular", size: 12)
            label.textColor = .black
            stackView.addArrangedSubview(label)
        }
        stackView.backgroundColor = UIColor(hex: 0xF5F5FB)
        return stackView
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.backgroundColor = UIColor(hex: 0xF5F5FB)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true
        collectionView.register(MonthlyCalendarCell.self, forCellWithReuseIdentifier: MonthlyCalendarCell.reuseIdentifier)
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        print("fatal error")
    }
}

// MARK: Configure
extension HomeCalendarView {
    func configureLayout() {
        weekStackView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(25)
            $0.leading.equalTo(self.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(weekStackView.snp.bottom).offset(10)
            $0.leading.equalTo(weekStackView.snp.leading)
            $0.trailing.equalTo(weekStackView.snp.trailing)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        yearMonthButton.snp.makeConstraints {
            $0.width.equalTo(150)
            $0.height.equalTo(44)
        }
    }

    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.addSubview(collectionView)
        self.addSubview(weekStackView)
    }
}

// MARK: Compositional layout
extension HomeCalendarView {

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


final class HomeCalendarViewController: UIViewController {
    
    var bag = DisposeBag()
    
    var homeCalendarView: HomeCalendarView?
    var viewModel: HomeCalendarViewModel?
    
    var isMonthChanged = PublishRelay<Date>()
    var isMultipleSelecting = PublishRelay<Bool>()
    var isMultipleSelected = PublishRelay<(Int, (Int, Int))>() //section, (item, item)
    var multipleTodoCompletionHandler: (() -> Void)?
    var isSingleSelected = PublishRelay<(Int, Int)>()
    var isGroupSelectedWithId = PublishRelay<Int?>()
    var refreshRequired = PublishRelay<Void>()
    var didFetchRefreshedData = PublishRelay<Void>()
    var initialCalendarGenerated = false
    
    let indexChanged = PublishRelay<Int>()
    
    convenience init(viewModel: HomeCalendarViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        let view = HomeCalendarView(frame: self.view.frame)
        self.view = view
        self.homeCalendarView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let homeCalendarView else { return }
        
        self.navigationItem.titleView = homeCalendarView.yearMonthButton
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: homeCalendarView.profileButton), animated: false)
    }
    
    func bind() {
        guard let viewModel,
              let homeCalendarView else { return }
        
        homeCalendarView.collectionView.delegate = self
        homeCalendarView.collectionView.dataSource = self
                
        viewModel.todoCompletionHandler = { [weak self] indexPath in
            guard let cell = homeCalendarView.collectionView.cellForItem(
                at: indexPath
            ) as? MonthlyCalendarCell else { return }
            cell.deselectItems()
        }
        
        let input = HomeCalendarViewModel.Input(
            didScrollToIndex: indexChanged.distinctUntilChanged().asObservable(),
            viewDidLoaded: Observable.just(()),
            didSelectItem: isSingleSelected.asObservable(),
            didMultipleSelectItemsInRange: isMultipleSelected.asObservable(),
            didTappedTitleButton: homeCalendarView.yearMonthButton.rx.tap.asObservable(),
            didSelectMonth: isMonthChanged.asObservable(),
            filterGroupWithId: isGroupSelectedWithId.asObservable(),
            refreshRequired: refreshRequired.asObservable(),
            profileBtnTapped: homeCalendarView.profileButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.didLoadYYYYMM
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { vc, text in
                homeCalendarView.yearMonthButton.setTitle(text, for: .normal)
            }
            .disposed(by: bag)
        
        output.initialDayListFetchedInCenterIndex
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, center in
                homeCalendarView.collectionView.performBatchUpdates({
                    vc.clearMonthUICache()
                    homeCalendarView.collectionView.reloadData()
                }, completion: { _ in
                    homeCalendarView.collectionView.contentOffset = CGPoint(x: CGFloat(center) * vc.view.frame.width, y: 0)
                    vc.initialCalendarGenerated = true
                })
            })
            .disposed(by: bag)
            
        output.todoListFetchedInIndexRange
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, rangeSet in
                vc.clearMonthUICache()
                homeCalendarView.collectionView.reloadSections(IndexSet(rangeSet.0..<rangeSet.1))
            })
            .disposed(by: bag)
        
        output.showMonthPicker
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, args in
                vc.showMonthPicker(firstYear: args.0, current: args.1, lastYear: args.2)
            })
            .disposed(by: bag)
        
        output.monthChangedByPicker
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                homeCalendarView.collectionView.setContentOffset(CGPoint(x: Double(index)*vc.view.frame.width, y: 0), animated: false)
            })
            .disposed(by: bag)
        
        isMultipleSelecting
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { bool in
                homeCalendarView.collectionView.isScrollEnabled = !bool
                homeCalendarView.collectionView.isUserInteractionEnabled = !bool
            })
            .disposed(by: bag)
        
        output.needReloadSectionSet
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, indexSet in
                UIView.performWithoutAnimation({
                    vc.clearMonthUICache()
                    homeCalendarView.collectionView.reloadSections(indexSet)
                })
            })
            .disposed(by: bag)
        
        output.needReloadData
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                UIView.performWithoutAnimation({
                    vc.clearMonthUICache()
                    homeCalendarView.collectionView.reloadData()
                })
            })
            .disposed(by: bag)
        
        output.profileImageFetched
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, data in
                homeCalendarView.profileButton.fill(with: data)
            })
            .disposed(by: bag)
        
        output.needWelcome
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message, type: .normal)
            })
            .disposed(by: bag)
        
        output
            .groupListFetched
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.setGroupButton()
            })
            .disposed(by: bag)
        
        output
            .needFilterGroupWithId
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.clearMonthUICache()
                homeCalendarView.collectionView.reloadData()
            })
            .disposed(by: bag)
        
        output
            .didFinishRefreshing
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.didFetchRefreshedData.accept(())
            })
            .disposed(by: bag)
        
        output
            .needScrollToHome
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                                homeCalendarView.collectionView.setContentOffset(
                               CGPoint(x: CGFloat(100) * vc.view.frame.width, y: 0), animated: false)
                            })
            })
            .disposed(by: bag)
            
    }
    
    func setGroupButton() {
        let image = UIImage(named: "groupCalendarList")
        var children = [UIMenuElement]()
        let all = UIAction(title: "모아 보기", handler: { [weak self] _ in
            self?.isGroupSelectedWithId.accept(nil)
        })
        children.append(all)
        if let groupDict = viewModel?.groups {
            let groupList = Array(groupDict.values)
            let sortedList = groupList.sorted(by: { $0.groupId < $1.groupId })
            
            sortedList.enumerated().forEach { index, groupName in
                let group = UIAction(title: groupName.groupName, handler: { [weak self] _ in
                    self?.isGroupSelectedWithId.accept(groupName.groupId)
                })
                children.append(group)
            }
        }
        
        let buttonMenu = UIMenu(options: .displayInline, children: children)
        
        let item = UIBarButtonItem(image: image, menu: buttonMenu)
        item.tintColor = UIColor(hex: 0x000000)
        navigationItem.setLeftBarButton(item, animated: true)
        homeCalendarView?.groupListButton = item
    }
    
    func clearMonthUICache() {
        viewModel?.weekDayChecker = [Int](repeating: -1, count: 6)
    }
    
    func showMonthPicker(firstYear: Date, current: Date, lastYear: Date) {
        guard let homeCalendarView else { return }
        
        let vc = MonthPickerViewController(firstYear: firstYear, lastYear: lastYear, currentDate: current) { [weak self] date in
            self?.isMonthChanged.accept(date)
        }

        vc.preferredContentSize = CGSize(width: 320, height: 290)
        vc.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        let globalFrame = homeCalendarView.yearMonthButton.convert(homeCalendarView.yearMonthButton.bounds, to: nil)
        popover.sourceRect = CGRect(x: globalFrame.midX, y: globalFrame.maxY, width: 0, height: 0)
        popover.permittedArrowDirections = [.up]
        self.present(vc, animated: true, completion:nil)
    }
    
    
}

// MARK: PopoverPresentationDelegate

extension HomeCalendarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: CollectionView DataSource, Delegate

extension HomeCalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.mainDays.count ?? Int()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthlyCalendarCell.reuseIdentifier, for: indexPath) as? MonthlyCalendarCell,
            let viewModel else { return UICollectionViewCell() }
        
        cell.fill(
            section: indexPath.section,
            viewModel: viewModel
        )
        
        cell.fill(
            isMultipleSelecting: isMultipleSelecting,
            isMultipleSelected: isMultipleSelected,
            isSingleSelected: isSingleSelected,
            refreshRequired: refreshRequired,
            didFetchRefreshedData: didFetchRefreshedData
        )
            
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) { //이거를 저거 끝나고 잇자
        let floatedIndex = scrollView.contentOffset.x/scrollView.bounds.width
        guard !(floatedIndex.isNaN || floatedIndex.isInfinite) && initialCalendarGenerated else { return }
        indexChanged.accept(Int(round(floatedIndex)))
    }
    
}

// MARK: configureVC

extension HomeCalendarViewController {

}

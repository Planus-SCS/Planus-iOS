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
    
    var isMonthChanged = PublishSubject<Date>()
    var isMultipleSelecting = PublishSubject<Bool>()
    var isMultipleSelected = PublishSubject<(Int, (Int, Int))>()
    var multipleTodoCompletionHandler: (() -> Void)?
    var isSingleSelected = PublishSubject<(Int, Int)>()
    var isGroupSelectedWithId = PublishSubject<Int?>()
    var refreshRequired = PublishSubject<Void>()
    var didFetchRefreshedData = PublishSubject<Void>()
    var initialCalendarGenerated = false
    
    let indexChanged = PublishSubject<Int>()
    
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
    
    var groupListButton: UIBarButtonItem?
    
//    var profileButton
    lazy var profileButton: ProfileButton = {
        let button = ProfileButton(frame: .zero)
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var profileBarButton: UIBarButtonItem = {
        let item = UIBarButtonItem(customView: profileButton)
        return item
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.titleView = yearMonthButton
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = HomeCalendarViewModel.Input(
            didScrollToIndex: indexChanged.distinctUntilChanged().asObservable(),
            viewDidLoaded: Observable.just(()),
            didSelectItem: isSingleSelected.asObservable(),
            didMultipleSelectItemsInRange: isMultipleSelected.asObservable(),
            didTappedTitleButton: yearMonthButton.rx.tap.asObservable(),
            didSelectMonth: isMonthChanged.asObservable(),
            filterGroupWithId: isGroupSelectedWithId.asObservable(),
            refreshRequired: refreshRequired.asObservable()
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
                vc.collectionView.performBatchUpdates({
                    viewModel.filteredWeeksOfYear = [Int](repeating: -1, count: 6)
                    vc.collectionView.reloadData()
                }, completion: { _ in
                    vc.collectionView.contentOffset = CGPoint(x: CGFloat(center) * vc.view.frame.width, y: 0)
                    vc.initialCalendarGenerated = true
                })
            })
            .disposed(by: bag)
            
        output.todoListFetchedInIndexRange
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, rangeSet in //여기서 추가로 리로드중인게 있는지 확인해야하나???
                viewModel.filteredWeeksOfYear = [Int](repeating: -1, count: 6)
                vc.collectionView.reloadSections(IndexSet(rangeSet.0..<rangeSet.1))
            })
            .disposed(by: bag)
        
        output.showDailyTodoPage
            .withUnretained(self)
            .subscribe(onNext: { vc, dayViewModel in
                viewModel.actions.showDailyCalendarPage?(DailyCalendarViewModel.Args(
                    currentDate: dayViewModel.date,
                    todoList: viewModel.todos[dayViewModel.date] ?? [],
                    categoryDict: viewModel.memberCategories ,
                    groupDict: viewModel.groups ,
                    groupCategoryDict: viewModel.groupCategories ,
                    filteringGroupId: try? vc.viewModel?.filteredGroupId.value()
                ))
            })
            .disposed(by: bag)
        
        isMultipleSelected
            .subscribe(onNext: { indexRange in
                var startDate = viewModel.mainDays[indexRange.0][indexRange.1.0].date
                var endDate = viewModel.mainDays[indexRange.0][indexRange.1.1].date
                
                if startDate > endDate {
                    swap(&startDate, &endDate)
                }

                let groupList = Array(viewModel.groups.values).sorted(by: { $0.groupId < $1.groupId })
                
                var groupName: GroupName?
                if let filteredGroupId = try? viewModel.filteredGroupId.value(),
                   let filteredGroupName = viewModel.groups[filteredGroupId] {
                    groupName = filteredGroupName
                }
                
                viewModel.actions.showCreatePeriodTodoPage?(
                    TodoDetailViewModelArgs(
                        groupList: groupList,
                        mode: .new,
                        todo: nil,
                        category: nil,
                        groupName: groupName,
                        start: startDate,
                        end: endDate
                    )
                ) { [weak self] in
                    guard let cell = self?.collectionView.cellForItem(
                        at: IndexPath(item: 0, section: indexRange.0)
                    ) as? MonthlyCalendarCell else { return }
                    cell.deselectItems()
                }
            })
            .disposed(by: bag)
        
        output.showMonthPicker
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { first, current, last in
                let vc = MonthPickerViewController(firstYear: first, lastYear: last, currentDate: current) { [weak self] date in
                    self?.isMonthChanged.onNext(date)
                }

                vc.preferredContentSize = CGSize(width: 320, height: 290)
                vc.modalPresentationStyle = .popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.delegate = self
                popover.sourceView = self.view
                let globalFrame = self.yearMonthButton.convert(self.yearMonthButton.bounds, to: nil)
                popover.sourceRect = CGRect(x: globalFrame.midX, y: globalFrame.maxY, width: 0, height: 0)
                popover.permittedArrowDirections = [.up]
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
        
        isMultipleSelecting
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { bool in
                self.collectionView.isScrollEnabled = !bool
                self.collectionView.isUserInteractionEnabled = !bool
            })
            .disposed(by: bag)
        
        output.needReloadSectionSet
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, indexSet in
                UIView.performWithoutAnimation({
                    viewModel.filteredWeeksOfYear = [Int](repeating: -1, count: 6)
                    vc.collectionView.reloadSections(indexSet)
                })
            })
            .disposed(by: bag)
        
        output.needReloadData
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                UIView.performWithoutAnimation({
                    viewModel.filteredWeeksOfYear = [Int](repeating: -1, count: 6)
                    vc.collectionView.reloadData()
                })
            })
            .disposed(by: bag)
        
        output.profileImageFetched
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, data in
                vc.profileButton.fill(with: data)
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
                viewModel.filteredWeeksOfYear = [Int](repeating: -1, count: 6)
                vc.collectionView.reloadData()
            })
            .disposed(by: bag)
        
        output
            .didFinishRefreshing
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.didFetchRefreshedData.onNext(())
            })
            .disposed(by: bag)
        
        output //이거는 처리를 하고 옮기기만 하는게 나을거같다..!!!! 그래도 될듯???
            .needScrollToHome
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                                vc.collectionView.setContentOffset(
                               CGPoint(x: CGFloat(100) * vc.view.frame.width, y: 0), animated: false)
                            })
            })
            .disposed(by: bag)
            
    }
    
    func setGroupButton() {
        let image = UIImage(named: "groupCalendarList")
        var children = [UIMenuElement]()
        let all = UIAction(title: "모아 보기", handler: { [weak self] _ in
            self?.groupSelected(id: nil)
        })
        children.append(all)
        if let groupDict = viewModel?.groups {
            let groupList = Array(groupDict.values)
            let sortedList = groupList.sorted(by: { $0.groupId < $1.groupId })
            
            sortedList.enumerated().forEach { index, groupName in
                let group = UIAction(title: groupName.groupName, handler: { [weak self] _ in
                    self?.groupSelected(id: groupName.groupId)
                })
                children.append(group)
            }
        }
        
        let buttonMenu = UIMenu(options: .displayInline, children: children)
        
        let item = UIBarButtonItem(image: image, menu: buttonMenu)
        item.tintColor = UIColor(hex: 0x000000)
        navigationItem.setLeftBarButton(item, animated: true)
        self.groupListButton = item
    }
    
    func groupSelected(id: Int?) {
        isGroupSelectedWithId.onNext(id)
    }
    

    @objc func profileButtonTapped() {
        guard let profile = viewModel?.profile else { return }
        viewModel?.actions.showMyPage?(profile)
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
        indexChanged.onNext(Int(round(floatedIndex)))
        print(Int(round(floatedIndex)))
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
            $0.height.equalTo(44)
        }
    }

    func configureView() {
        self.navigationItem.setLeftBarButton(groupListButton, animated: false)
        self.navigationItem.setRightBarButton(profileBarButton, animated: false)
        self.view.addSubview(collectionView)
        self.view.addSubview(weekStackView)
    }
}

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
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
    
}

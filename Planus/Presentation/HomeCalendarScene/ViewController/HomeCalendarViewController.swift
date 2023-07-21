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
    
    let scrolledTo = PublishSubject<ScrollDirection>()
    
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
            didScrollTo: self.scrolledTo.asObservable(),
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
                vc.collectionView.reloadData()
                vc.collectionView.contentOffset = CGPoint(x: CGFloat(center) * vc.view.frame.width, y: 0)
            })
            .disposed(by: bag)
            
        output.todoListFetchedInIndexRange
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, rangeSet in //여기서 추가로 리로드중인게 있는지 확인해야하나???
                vc.collectionView.reloadSections(IndexSet(rangeSet.0..<rangeSet.1))
            })
            .disposed(by: bag)
        
        output.showDailyTodoPage
            .withUnretained(self)
            .subscribe(onNext: { vc, dayViewModel in
                let api = NetworkManager()
                let keyChain = KeyChainManager()
                let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
                let categoryRepo = DefaultCategoryRepository(apiProvider: api)

                let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
                let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
                let createTodoUseCase = DefaultCreateTodoUseCase.shared
                let updateTodoUseCase = DefaultUpdateTodoUseCase.shared
                let deleteTodoUseCase = DefaultDeleteTodoUseCase.shared
                let createCategoryUseCase = DefaultCreateCategoryUseCase.shared
                let updateCategoryUseCase = DefaultUpdateCategoryUseCase.shared
                let deleteCategoryUseCase = DefaultDeleteCategoryUseCase.shared
                let readCategoryUseCase = DefaultReadCategoryListUseCase(categoryRepository: categoryRepo)
                
                
                let viewModel = TodoDailyViewModel(
                    getTokenUseCase: getTokenUseCase,
                    refreshTokenUseCase: refreshTokenUseCase,
                    createTodoUseCase: createTodoUseCase,
                    updateTodoUseCase: updateTodoUseCase,
                    deleteTodoUseCase: deleteTodoUseCase,
                    todoCompleteUseCase: DefaultTodoCompleteUseCase.shared,
                    createCategoryUseCase: createCategoryUseCase,
                    updateCategoryUseCase: updateCategoryUseCase,
                    deleteCategoryUseCase: deleteCategoryUseCase,
                    readCategoryUseCase: readCategoryUseCase
                )
                
                viewModel.setDate(currentDate: dayViewModel.date)
                viewModel.setTodoList(
                    todoList: vc.viewModel?.todos[dayViewModel.date] ?? [],
                    categoryDict: vc.viewModel?.memberCategories ?? [:],
                    groupDict: vc.viewModel?.groups ?? [:],
                    groupCategoryDict: vc.viewModel?.groupCategories ?? [:],
                    filteringGroupId: try? vc.viewModel?.filteredGroupId.value()
                ) //투두리스트를 필터링해야함..! 아니 걍 다 올리고 저짝에서 필터링하자 그게 편하다..!
                viewModel.setOwnership(isOwner: true)
                let viewController = TodoDailyViewController(viewModel: viewModel)
                let nav = UINavigationController(rootViewController: viewController)
                nav.modalPresentationStyle = .pageSheet
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                }
                vc.present(nav, animated: true)
                
                // viewController에 completionHandler를 달아야함. 어떻게 달까??
            })
            .disposed(by: bag)
        
        isMultipleSelected
            .subscribe(onNext: { indexRange in
                var startDate = viewModel.mainDays[indexRange.0][indexRange.1.0].date
                var endDate = viewModel.mainDays[indexRange.0][indexRange.1.1].date
                
                if startDate > endDate {
                    swap(&startDate, &endDate)
                }
                
                let api = NetworkManager()
                let keyChain = KeyChainManager()
                
                let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
                let todoRepo = TestTodoDetailRepository(apiProvider: api)
                let categoryRepo = DefaultCategoryRepository(apiProvider: api)
                
                let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
                let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
                let createTodoUseCase = DefaultCreateTodoUseCase.shared
                let updateTodoUseCase = DefaultUpdateTodoUseCase.shared
                let deleteTodoUseCase = DefaultDeleteTodoUseCase.shared
                let createCategoryUseCase = DefaultCreateCategoryUseCase.shared
                let updateCategoryUseCase = DefaultUpdateCategoryUseCase.shared
                let readCateogryUseCase = DefaultReadCategoryListUseCase(categoryRepository: categoryRepo)
                let deleteCategoryUseCase = DefaultDeleteCategoryUseCase.shared
                
                let vm = TodoDetailViewModel(
                    getTokenUseCase: getTokenUseCase,
                    refreshTokenUseCase: refreshTokenUseCase,
                    createTodoUseCase: createTodoUseCase,
                    updateTodoUseCase: updateTodoUseCase,
                    deleteTodoUseCase: deleteTodoUseCase,
                    createCategoryUseCase: createCategoryUseCase,
                    updateCategoryUseCase: updateCategoryUseCase,
                    deleteCategoryUseCase: deleteCategoryUseCase,
                    readCategoryUseCase: readCateogryUseCase
                )
                
                let groupList = Array(viewModel.groups.values).sorted(by: { $0.groupId < $1.groupId })
                vm.setGroup(groupList: groupList)
                vm.todoStartDay.onNext(startDate)
                vm.todoEndDay.onNext((startDate == endDate) ? nil : endDate)
                
                let vc = TodoDetailViewController(viewModel: vm)
                vc.completionHandler = { [weak self] in
                    guard let cell = self?.collectionView.cellForItem(at: IndexPath(item: 0, section: indexRange.0)) as? MonthlyCalendarCell else { return }
                    cell.deselectItems()
                }
                
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false, completion: nil)
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
                popover.sourceItem = self.yearMonthButton
                
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
                    vc.collectionView.reloadSections(indexSet)
                })
            })
            .disposed(by: bag)
        
        output.needReloadData
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                UIView.performWithoutAnimation({
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
                print("fetched!!!")
                vc.setGroupButton()
            })
            .disposed(by: bag)
        
        output
            .needFilterGroupWithId
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
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
        let api = NetworkManager()
        let keyChain = KeyChainManager()
        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
        let profileRepo = DefaultProfileRepository(apiProvider: api)
        let imageRepo = DefaultImageRepository(apiProvider: api)
        let readProfileUseCase = DefaultReadProfileUseCase(profileRepository: profileRepo)
        let updateProfileUseCase = DefaultUpdateProfileUseCase(profileRepository: profileRepo)
        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
        let fetchImageUseCase = DefaultFetchImageUseCase(imageRepository: imageRepo)
        let vm = MyPageMainViewModel(updateProfileUseCase: updateProfileUseCase, getTokenUseCase: getTokenUseCase, refreshTokenUseCase: refreshTokenUseCase, fetchImageUseCase: fetchImageUseCase)
        vm.setProfile(profile: profile)
        let vc = MyPageMainViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
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
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
    
}

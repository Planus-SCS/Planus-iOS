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
    var isSingleSelected = PublishSubject<(Int, Int)>()
    
    let scrolledTo = PublishSubject<ScrollDirection>()
    
    lazy var yearMonthButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.setImage(UIImage(named: "downButton"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: -5)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)

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
            didSelectMonth: isMonthChanged.asObservable()
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
                    createCategoryUseCase: createCategoryUseCase,
                    updateCategoryUseCase: updateCategoryUseCase,
                    deleteCategoryUseCase: deleteCategoryUseCase,
                    readCategoryUseCase: readCategoryUseCase
                )
                
                viewModel.setDate(currentDate: dayViewModel.date)
                viewModel.setTodoList(
                    todoList: dayViewModel.todoList ?? [],
                    categoryDict: vc.viewModel?.categoryDict ?? [:],
                    groupDict: vc.viewModel?.groupDict ?? [:]
                )

                let viewController = TodoDailyViewController(viewModel: viewModel)
                let nav = UINavigationController(rootViewController: viewController)
                nav.modalPresentationStyle = .pageSheet
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                }
                vc.present(nav, animated: true)
            })
            .disposed(by: bag)
        
        output.showCreateMultipleTodo
            .subscribe(onNext: { dateRange in
                print(dateRange)
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
                print("홈화면에 업댓된게 전해짐!", data)
                vc.profileButton.fill(with: data)
            })
            .disposed(by: bag)
    }
    

    @objc func profileButtonTapped() {
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
        let vm = MyPageMainViewModel(readProfileUseCase: readProfileUseCase, updateProfileUseCase: updateProfileUseCase, getTokenUseCase: getTokenUseCase, refreshTokenUseCase: refreshTokenUseCase, fetchImageUseCase: fetchImageUseCase)
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
        viewModel?.mainDayList.count ?? Int()
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

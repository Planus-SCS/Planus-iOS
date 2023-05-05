//
//  TodoDailyViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift

class TodoDailyViewController: UIViewController {
    
    var bag = DisposeBag()
    var viewModel: TodoDailyViewModel?
    
    var didDeleteTodoAt = PublishSubject<IndexPath>()
    
    lazy var dateTitleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.setTitleColor(.black, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var addTodoButton: UIBarButtonItem = {
        let image = UIImage(named: "plusBtn")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addTodoTapped))
        item.tintColor = .black
        return item
    }()
    
    lazy var collectionView: TodoDailyCollectionView = {
        let cv = TodoDailyCollectionView(frame: .zero)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    convenience init(viewModel: TodoDailyViewModel) {
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
        
        bind()
        
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = dateTitleButton
        navigationItem.setRightBarButton(addTodoButton, animated: false)
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = TodoDailyViewModel.Input(
            deleteTodoAt: didDeleteTodoAt.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        addTodoButton.isHidden = !(output.isOwner ?? true)
        dateTitleButton.setTitle(output.currentDateText, for: .normal)
        
        output
            .needReloadItem
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                vm.collectionView.reloadItems(at: [indexPath])
            })
            .disposed(by: bag)
        
        output
            .needInsertItem
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                vm.collectionView.insertItems(at: [indexPath])
            })
            .disposed(by: bag)
            
        output
            .needDeleteItem
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                vm.collectionView.deleteItems(at: [indexPath])
            })
            .disposed(by: bag)
        
        output
            .needReloadData
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.collectionView.reloadData()
            })
            .disposed(by: bag)

    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(collectionView)
    }
    
    func configureLayout() {
        dateTitleButton.snp.makeConstraints {
            $0.width.equalTo(160)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc func addTodoTapped(_ sender: UIButton) {
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
        vm.todoStartDay.onNext(viewModel?.currentDate)
        let vc = TodoDetailViewController(viewModel: vm)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
//    @objc func dateTitleBtnTapped(_ sender: UIButton) {
//        showSmallCalendar()
//    }
    
//    private func showSmallCalendar() {
//
//        guard let viewModel = self.viewModel else {
//            return
//        }
//
//        if let sheet = self.sheetPresentationController {
//            sheet.invalidateDetents()
//        }
//
//        let vm = SmallCalendarViewModel()
//        vm.completionHandler = { [weak self] date in
//            self?.didChangeDate.onNext(date)
//        }
//        vm.configureDate(currentDate: viewModel.currentDate ?? Date(), min: viewModel.minDate ?? Date(), max: viewModel.maxDate ?? Date())
//        let vc = SmallCalendarViewController(viewModel: vm)
//
//        vc.preferredContentSize = CGSize(width: 320, height: 400)
//        vc.modalPresentationStyle = .popover
//
//        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = self.view
//        popover.sourceItem = dateTitleButton
//
//        present(vc, animated: true, completion:nil)
//    }
}

extension TodoDailyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel?.scheduledTodoList?.count ?? 0
        case 1:
            return viewModel?.unscheduledTodoList?.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BigTodoCell.reuseIdentifier, for: indexPath) as? BigTodoCell else {
            return UICollectionViewCell()
        }
        
        var todoItem: Todo?
        switch indexPath.section {
        case 0:
            todoItem = viewModel?.scheduledTodoList?[indexPath.item]
        case 1:
            todoItem = viewModel?.unscheduledTodoList?[indexPath.item]
        default:
            return UICollectionViewCell()
        }
        guard let todoItem,
              let category = viewModel?.categoryDict[todoItem.categoryId] else {
            return UICollectionViewCell()
        }
        
        cell.fill(title: todoItem.title, time: todoItem.startTime, category: category.color, isGroup: todoItem.groupId != nil, isScheduled: todoItem.startTime != nil, isMemo: todoItem.memo != nil, completion: false)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: TodoDailyCollectionView.headerKind, withReuseIdentifier: TodoSectionHeaderSupplementaryView.reuseIdentifier, for: indexPath) as? TodoSectionHeaderSupplementaryView else { return UICollectionReusableView() }
        
        var title: String
        switch indexPath.section {
        case 0:
            title = "일정"
        case 1:
            title = "투두"
        default:
            return UICollectionReusableView()
        }
        headerview.fill(title: title)
     
        return headerview
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        var item: Todo?
        switch indexPath.section {
        case 0:
            item = viewModel?.scheduledTodoList?[indexPath.item]
        case 1:
            item = viewModel?.unscheduledTodoList?[indexPath.item]
        default:
            return false
        }
        guard let item else { return false }
        
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
        guard let category = viewModel?.categoryDict[item.categoryId] else { return false }
        vm.setForEdit(todo: item, category: category)
        vm.todoStartDay.onNext(viewModel?.currentDate)
        let vc = TodoDetailViewController(viewModel: vm)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
        
        return false
    }
}

extension TodoDailyViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

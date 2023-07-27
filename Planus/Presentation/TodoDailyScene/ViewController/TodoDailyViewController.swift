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
    
    var didTappedCompletionBtnAt = PublishSubject<IndexPath>()
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
            deleteTodoAt: didDeleteTodoAt.asObservable(),
            completeTodoAt: didTappedCompletionBtnAt.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
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
                if indexPath.section == 0 {
                    if vm.viewModel?.scheduledTodoList?.count == 1 {
                        vm.collectionView.deleteItems(at: [indexPath])
                    }
                } else if indexPath.section == 1 {
                    if vm.viewModel?.unscheduledTodoList?.count == 1 {
                        vm.collectionView.deleteItems(at: [indexPath])
                    }
                }
                
                vm.collectionView.insertItems(at: [indexPath])
            })
            .disposed(by: bag)
            
        output
            .needDeleteItem
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                vm.collectionView.performBatchUpdates({
                    vm.collectionView.deleteItems(at: [indexPath])
                }, completion: { _ in
                    UIView.performWithoutAnimation {
                        vm.collectionView.reloadSections(IndexSet(0...1))
                    }
                })
                if indexPath.section == 0 {
                    if vm.viewModel?.scheduledTodoList?.count == 0 {
                        vm.collectionView.insertItems(at: [indexPath])
                    }
                } else if indexPath.section == 1 {
                    if vm.viewModel?.unscheduledTodoList?.count == 0 {
                        vm.collectionView.insertItems(at: [indexPath])
                    }
                }
            })
            .disposed(by: bag)
        
        output
            .needReloadData
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.collectionView.reloadSections(IndexSet(0...1))
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
        
        let vm = MemberTodoDetailViewModel(
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
        guard let groupDict = viewModel?.groupDict else { return }
        let groupList = Array(groupDict.values).sorted(by: { $0.groupId < $1.groupId })
        vm.setGroup(groupList: groupList)
        
        var groupName: GroupName?
        if let filteredGroupId = viewModel?.filteringGroupId,
           let filteredGroupName = groupDict[filteredGroupId] {
            groupName = filteredGroupName
        }
        vm.initMode(mode: .new, groupName: groupName, start: viewModel?.currentDate)
        let vc = TodoDetailViewController(viewModel: vm)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }

}

extension TodoDailyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            let count = viewModel?.scheduledTodoList?.count ?? 0
            return count == 0 ? 1 : count
        case 1:
            let count = viewModel?.unscheduledTodoList?.count ?? 0
            return count == 0 ? 1 : count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var todoItem: Todo?
        switch indexPath.section {
        case 0:
            if let scheduledList = viewModel?.scheduledTodoList,
               !scheduledList.isEmpty {
                todoItem = scheduledList[indexPath.item]
            } else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: EmptyTodoMockCell.reuseIdentifier, for: indexPath)
            }
        case 1:
            if let unscheduledList = viewModel?.unscheduledTodoList,
               !unscheduledList.isEmpty {
                todoItem = unscheduledList[indexPath.item]
            } else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: EmptyTodoMockCell.reuseIdentifier, for: indexPath)
            }
        default:
            return UICollectionViewCell()
        }
        guard let todoItem else { return UICollectionViewCell() }
        
        var category: Category?
        category = todoItem.isGroupTodo ?
        viewModel?.groupCategoryDict[todoItem.categoryId]
        : viewModel?.categoryDict[todoItem.categoryId]
        
        guard let category else { return UICollectionViewCell() }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BigTodoCell.reuseIdentifier, for: indexPath) as? BigTodoCell else {
            return UICollectionViewCell()
        }
        
        cell.fill(
            title: todoItem.title,
            time: todoItem.startTime,
            category: category.color,
            isGroup: todoItem.isGroupTodo,
            isScheduled: todoItem.startDate != todoItem.endDate,
            isMemo: todoItem.memo != nil,
            completion: todoItem.isCompleted,
            isOwner: true
        )
        
        cell.fill { [weak self] in
            self?.didTappedCompletionBtnAt.onNext(indexPath)
        }
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
        print("a")
        switch indexPath.section {
        case 0:
            if let scheduledList = viewModel?.scheduledTodoList,
               !scheduledList.isEmpty {
                item = scheduledList[indexPath.item]
            } else {
                return false
            }
        case 1:
            if let unscheduledList = viewModel?.unscheduledTodoList,
               !unscheduledList.isEmpty {
                item = unscheduledList[indexPath.item]
            } else {
                return false
            }
        default:
            return false
        }
        print("b")
        guard let item else { return false }
        print("c")
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
        let readCateogryUseCase = DefaultReadCategoryListUseCase(categoryRepository: categoryRepo)
        let deleteCategoryUseCase = DefaultDeleteCategoryUseCase.shared
        
        let vm = MemberTodoDetailViewModel(
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
        
        if item.isGroupTodo {
            guard let groupId = item.groupId,
                  let category = viewModel?.groupCategoryDict[item.categoryId] else { return false }
            let groupName = viewModel?.groupDict[groupId]
            vm.initMode(mode: .view, todo: item, category: category, groupName: groupName)
        } else {
            guard let groupDict = viewModel?.groupDict else { return false }
            let groupList = Array(groupDict.values).sorted(by: { $0.groupId < $1.groupId })
            vm.setGroup(groupList: groupList)
            guard let category = viewModel?.categoryDict[item.categoryId] else { return false }
            var groupName: GroupName?
            if let groupId = item.groupId {
                groupName = groupDict[groupId]
            }
            
            vm.initMode(mode: .edit, todo: item, category: category, groupName: groupName)
        }


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

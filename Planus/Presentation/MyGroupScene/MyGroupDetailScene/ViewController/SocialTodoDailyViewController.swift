//
//  SocialTodoDailyViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import UIKit
import RxSwift

class SocialTodoDailyViewController: UIViewController {
    
    var bag = DisposeBag()
    var viewModel: SocialTodoDailyViewModel?
    
    var didDeleteTodoAt = PublishSubject<IndexPath>()
    
    var spinner = UIActivityIndicatorView(style: .medium)

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
    
    convenience init(viewModel: SocialTodoDailyViewModel) {
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = dateTitleButton
        navigationItem.setRightBarButton(addTodoButton, animated: false)
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = SocialTodoDailyViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        let output = viewModel.transform(input: input)
                
        spinner.isHidden = false
        spinner.startAnimating()
        collectionView.setAnimatedIsHidden(true, duration: 0)
        print("load")
        
        output
            .didFetchTodoList
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                print("fetched")
                vc.collectionView.reloadData()
                vc.spinner.setAnimatedIsHidden(true, duration: 0.2, onCompletion: {
                    vc.spinner.stopAnimating()
                    vc.collectionView.setAnimatedIsHidden(false, duration: 0.2)
                })
            })
            .disposed(by: bag)
        
        dateTitleButton.setTitle(output.currentDateText, for: .normal)

        guard let type = output.socialType else { return }
        
        switch type {
        case .member(let id):
            addTodoButton.isHidden = true
        case .group(let isLeader):
            addTodoButton.isHidden = !(isLeader ?? false)
        }
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(collectionView)
        self.view.addSubview(spinner)
    }
    
    func configureLayout() {
        dateTitleButton.snp.makeConstraints {
            $0.width.equalTo(160)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        spinner.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(50)
        }
    }
    
    @objc func addTodoTapped(_ sender: UIButton) {
//        let api = NetworkManager()
//        let keyChain = KeyChainManager()
//
//        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
//        let todoRepo = TestTodoDetailRepository(apiProvider: api)
//        let categoryRepo = DefaultCategoryRepository(apiProvider: api)
//
//        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
//        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
//        let createTodoUseCase = DefaultCreateTodoUseCase.shared
//        let updateTodoUseCase = DefaultUpdateTodoUseCase.shared
//        let deleteTodoUseCase = DefaultDeleteTodoUseCase.shared
//        let createCategoryUseCase = DefaultCreateCategoryUseCase.shared
//        let updateCategoryUseCase = DefaultUpdateCategoryUseCase.shared
//        let readCateogryUseCase = DefaultReadCategoryListUseCase(categoryRepository: categoryRepo)
//        let deleteCategoryUseCase = DefaultDeleteCategoryUseCase.shared
//
//        let vm = TodoDetailViewModel(
//            getTokenUseCase: getTokenUseCase,
//            refreshTokenUseCase: refreshTokenUseCase,
//            createTodoUseCase: createTodoUseCase,
//            updateTodoUseCase: updateTodoUseCase,
//            deleteTodoUseCase: deleteTodoUseCase,
//            createCategoryUseCase: createCategoryUseCase,
//            updateCategoryUseCase: updateCategoryUseCase,
//            deleteCategoryUseCase: deleteCategoryUseCase,
//            readCategoryUseCase: readCateogryUseCase
//        )
//        guard let groupDict = viewModel?.groupDict else { return }
//        let groupList = Array(groupDict.values).sorted(by: { $0.groupId < $1.groupId })
//        vm.setGroup(groupList: groupList)
//        vm.todoStartDay.onNext(viewModel?.currentDate)
//        let vc = TodoDetailViewController(viewModel: vm)
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: false, completion: nil)
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

extension SocialTodoDailyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        var todoItem: SocialTodoDaily?
        
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
            print("4")
            return UICollectionViewCell()
        }
        guard let todoItem else {
            print("5")
            return UICollectionViewCell()
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BigTodoCell.reuseIdentifier, for: indexPath) as? BigTodoCell else {
            return UICollectionViewCell()
        }
        cell.fill(title: todoItem.title, time: todoItem.startTime, category: todoItem.categoryColor, isGroup: todoItem.hasGroup, isScheduled: todoItem.isPeriodTodo, isMemo: todoItem.hasDescription, completion: todoItem.isCompleted)
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
//        var todoId: Int?
//        switch indexPath.section {
//        case 0:
//            if viewModel?.scheduledTodoList?.count == 0 {
//                return false
//            } else {
//                todoId = viewModel?.scheduledTodoList?[indexPath.item].todoId
//            }
//        case 1:
//            if viewModel?.unscheduledTodoList?.count == 0 {
//                return false
//            } else {
//                todoId = viewModel?.unscheduledTodoList?[indexPath.item].todoId
//            }
//        default:
//            return false
//        }
//        guard let todoId,
//              let isOwner = viewModel?.isOwner else { return false }
//        let api = NetworkManager()
//        let keyChain = KeyChainManager()
//        
//        let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
//
//        let getTokenUseCase = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
//        let refreshTokenUseCase = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
//
////        let vm = TodoDetailViewModel(
////            getTokenUseCase: getTokenUseCase,
////            refreshTokenUseCase: refreshTokenUseCase,
////            createTodoUseCase: createTodoUseCase,
////            updateTodoUseCase: updateTodoUseCase,
////            deleteTodoUseCase: deleteTodoUseCase,
////            createCategoryUseCase: createCategoryUseCase,
////            updateCategoryUseCase: updateCategoryUseCase,
////            deleteCategoryUseCase: deleteCategoryUseCase,
////            readCategoryUseCase: readCateogryUseCase
////        )
////
////        guard let groupDict = viewModel?.groupDict else { return false }
////        let groupList = Array(groupDict.values).sorted(by: { $0.groupId < $1.groupId })
////        vm.setGroup(groupList: groupList)
////        guard let category = viewModel?.categoryDict[item.categoryId] else { return false }
////        var groupName: GroupName?
////        if let groupId = item.groupId {
////            groupName = groupDict[groupId]
////        }
////
////        if isOwner {
////            vm.setForEdit(todo: item, category: category, groupName: groupName)
////        } else {
////            vm.setForOthers(todo: item, category: category, groupName: groupName)
////        }
////        vm.todoStartDay.onNext(viewModel?.currentDate)
////        let vc = TodoDetailViewController(viewModel: vm)
////        vc.modalPresentationStyle = .overFullScreen
////        self.present(vc, animated: false, completion: nil)
//
        return false
    }

}

extension SocialTodoDailyViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

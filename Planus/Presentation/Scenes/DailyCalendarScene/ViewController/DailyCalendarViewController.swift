//
//  TodoDailyViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift

class DailyCalendarViewController: UIViewController {
    
    var bag = DisposeBag()
    var viewModel: DailyCalendarViewModel?
    
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
    
    lazy var collectionView: DailyCalendarCollectionView = {
        let cv = DailyCalendarCollectionView(frame: .zero)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    convenience init(viewModel: DailyCalendarViewModel) {
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
        
        let input = DailyCalendarViewModel.Input(
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
            .subscribe(onNext: { vc, indexPath in
                if (indexPath.section == 0 &&
                    viewModel.scheduledTodoList?.count == 0) ||
                    (indexPath.section == 1 &&
                     vc.viewModel?.unscheduledTodoList?.count == 0) {
                    vc.collectionView.reloadItems(at: [indexPath])
                } else {
                    vc.collectionView.insertItems(at: [indexPath])
                }
            })
            .disposed(by: bag)
            
        output
            .needDeleteItem
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, indexPath in
                if (indexPath.section == 0 &&
                    viewModel.scheduledTodoList?.count == 0) ||
                    (indexPath.section == 1 &&
                     vc.viewModel?.unscheduledTodoList?.count == 0) {
                    vc.collectionView.reloadItems(at: [indexPath])
                } else {
                    vc.collectionView.deleteItems(at: [indexPath])
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
        
        output
            .needMoveItem
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, args in
                let (from, to) = args
                
                vc.collectionView.performBatchUpdates { //to도 신경써야함. 지금 from만 보고있음. 만약 to섹션이 원래 비어있었다면?
                    if (from.section == 0 &&
                        viewModel.scheduledTodoList?.count == 0) ||
                        (from.section == 1 &&
                         vc.viewModel?.unscheduledTodoList?.count == 0) {
                        vc.collectionView.reloadItems(at: [from])
                        if (to.section == 0 &&
                            viewModel.scheduledTodoList?.count == 1) ||
                            (to.section == 1 &&
                             vc.viewModel?.unscheduledTodoList?.count == 1) {
                            vc.collectionView.reloadItems(at: [to])
                        } else {
                            vc.collectionView.insertItems(at: [to])
                        }
                    } else {
                        if (to.section == 0 &&
                            viewModel.scheduledTodoList?.count == 1) ||
                            (to.section == 1 &&
                             vc.viewModel?.unscheduledTodoList?.count == 1) {
                            vc.collectionView.deleteItems(at: [from])
                            vc.collectionView.reloadItems(at: [to])
                        } else {
                            vc.collectionView.deleteItems(at: [from])
                            vc.collectionView.insertItems(at: [to])
                        }
                    }
                }
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

        guard let groupDict = viewModel?.groupDict else { return }
        let groupList = Array(groupDict.values).sorted(by: { $0.groupId < $1.groupId })
        
        var groupName: GroupName?
        if let filteredGroupId = viewModel?.filteringGroupId,
           let filteredGroupName = groupDict[filteredGroupId] {
            groupName = filteredGroupName
        }

        
        viewModel?.actions.showTodoDetailPage?(
            TodoDetailViewModelArgs(
                groupList: groupList,
                mode: .new,
                todo: nil,
                category: nil,
                groupName: groupName,
                start: viewModel?.currentDate,
                end: nil
            ), nil
        )
    }

}

extension DailyCalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
                return collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarEmptyTodoMockCell.reuseIdentifier, for: indexPath)
            }
        case 1:
            if let unscheduledList = viewModel?.unscheduledTodoList,
               !unscheduledList.isEmpty {
                todoItem = unscheduledList[indexPath.item]
            } else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarEmptyTodoMockCell.reuseIdentifier, for: indexPath)
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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarTodoCell.reuseIdentifier, for: indexPath) as? DailyCalendarTodoCell else {
            return UICollectionViewCell()
        }
                
        cell.fill(
            title: todoItem.title,
            time: todoItem.startTime,
            category: category.color,
            isGroup: todoItem.isGroupTodo,
            isScheduled: todoItem.startDate != todoItem.endDate,
            isMemo: !(todoItem.memo ?? "").isEmpty,
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

        guard let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: DailyCalendarCollectionView.headerKind, withReuseIdentifier: DailyCalendarSectionHeaderSupplementaryView.reuseIdentifier, for: indexPath) as? DailyCalendarSectionHeaderSupplementaryView else { return UICollectionReusableView() }
        
        var title: String
        switch indexPath.section {
        case 0:
            title = "일정"
        case 1:
            title = "할일"
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
        guard let item else { return false }

        guard let groupDict = viewModel?.groupDict else { return false }
        let groupList = Array(groupDict.values).sorted(by: { $0.groupId < $1.groupId })
        var groupName: GroupName?
        var mode: TodoDetailSceneMode
        var category: Category?
        
        if item.isGroupTodo {
            guard let groupId = item.groupId else { return false }
            groupName = groupDict[groupId]
            mode = .view
            category = viewModel?.groupCategoryDict[item.categoryId]
        } else {
            if let groupId = item.groupId {
                groupName = groupDict[groupId]
            }
            mode = .edit
            category = viewModel?.categoryDict[item.categoryId]
        }

        viewModel?.actions.showTodoDetailPage?(
            TodoDetailViewModelArgs(
                groupList: groupList,
                mode: mode,
                todo: item,
                category: category,
                groupName: groupName,
                start: viewModel?.currentDate,
                end: nil
            ), nil
        )
        
        return false
    }

}

extension DailyCalendarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

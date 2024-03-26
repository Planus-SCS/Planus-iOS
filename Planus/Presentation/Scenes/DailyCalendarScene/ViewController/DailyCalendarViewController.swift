//
//  TodoDailyViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/06.
//

import UIKit
import RxSwift
import RxCocoa

final class DailyCalendarViewController: UIViewController {
    
    private var bag = DisposeBag()
    private var viewModel: DailyCalendarViewModel?
    private var dailyCalendarView: DailyCalendarView?
    
    private var didTappedCompletionBtnAt = PublishRelay<IndexPath>()
    private var didDeleteTodoAt = PublishRelay<IndexPath>()
    
    convenience init(viewModel: DailyCalendarViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        let view = DailyCalendarView(frame: self.view.frame)
        self.view = view
        self.dailyCalendarView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailyCalendarView?.collectionView.dataSource = self
        dailyCalendarView?.collectionView.delegate = self
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = dailyCalendarView?.dateTitleButton
        navigationItem.setRightBarButton(dailyCalendarView?.addTodoButton, animated: false)
        navigationController?.presentationController?.delegate = self
    }
}

// MARK: - bind viewModel
extension DailyCalendarViewController {
    func bind() {
        guard let viewModel,
              let dailyCalendarView else { return }
        
        let input = DailyCalendarViewModel.Input(
            addTodoTapped: dailyCalendarView.addTodoButton.rx.tap.asObservable(),
            todoSelectedAt: dailyCalendarView.collectionView.rx.itemSelected.asObservable(),
            deleteTodoAt: didDeleteTodoAt.asObservable(),
            completeTodoAt: didTappedCompletionBtnAt.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        dailyCalendarView.dateTitleButton.setTitle(output.currentDateText, for: .normal)
        
        output
            .needReloadItem
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                vm.dailyCalendarView?.collectionView.reloadItems(at: [indexPath])
            })
            .disposed(by: bag)
        
        output
            .needInsertItem
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, indexPath in
                vc.insertTodoAt(indexPath: indexPath)
            })
            .disposed(by: bag)
            
        output
            .needDeleteItem
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, indexPath in
                vc.deleteTodoAt(indexPath: indexPath)
            })
            .disposed(by: bag)
        
        output
            .needReloadData
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.dailyCalendarView?.collectionView.reloadSections(IndexSet(0...1))
            })
            .disposed(by: bag)
        
        output
            .needMoveItem
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, args in
                let (from, to) = args

                vc.moveTodo(from: from, to: to)
            })
            .disposed(by: bag)
        
        dailyCalendarView.collectionView.reloadData()
    }
}

// MARK: Actions
extension DailyCalendarViewController {
    func insertTodoAt(indexPath: IndexPath) {
        guard let viewModel else { return }
        
        if (indexPath.section == 0 &&
            viewModel.scheduledTodoList?.count == 1) ||
            (indexPath.section == 1 &&
             viewModel.unscheduledTodoList?.count == 1) {
            dailyCalendarView?.collectionView.reloadItems(at: [indexPath])
        } else {
            dailyCalendarView?.collectionView.insertItems(at: [indexPath])
        }
    }
    
    func deleteTodoAt(indexPath: IndexPath) {
        guard let viewModel else { return }
        
        if (indexPath.section == 0 &&
            viewModel.scheduledTodoList?.count == 0) ||
            (indexPath.section == 1 &&
             viewModel.unscheduledTodoList?.count == 0) {
            dailyCalendarView?.collectionView.reloadItems(at: [indexPath])
        } else {
            dailyCalendarView?.collectionView.deleteItems(at: [indexPath])
        }
    }
    
    func moveTodo(from: IndexPath, to: IndexPath) {
        guard let viewModel else { return }
        
        dailyCalendarView?.collectionView.performBatchUpdates {
            if (from.section == 0 &&
                viewModel.scheduledTodoList?.count == 0) ||
                (from.section == 1 &&
                 viewModel.unscheduledTodoList?.count == 0) {
                dailyCalendarView?.collectionView.reloadItems(at: [from])
                if (to.section == 0 &&
                    viewModel.scheduledTodoList?.count == 1) ||
                    (to.section == 1 &&
                     viewModel.unscheduledTodoList?.count == 1) {
                    dailyCalendarView?.collectionView.reloadItems(at: [to])
                } else {
                    dailyCalendarView?.collectionView.insertItems(at: [to])
                }
            } else {
                if (to.section == 0 &&
                    viewModel.scheduledTodoList?.count == 1) ||
                    (to.section == 1 &&
                     viewModel.unscheduledTodoList?.count == 1) {
                    dailyCalendarView?.collectionView.deleteItems(at: [from])
                    dailyCalendarView?.collectionView.reloadItems(at: [to])
                } else {
                    dailyCalendarView?.collectionView.deleteItems(at: [from])
                    dailyCalendarView?.collectionView.insertItems(at: [to])
                }
            }
        }
    }
}

// MARK: - modal dismiss handler
extension DailyCalendarViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel?.actions.finishScene?()
    }
}

// MARK: - collection View
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
            self?.didTappedCompletionBtnAt.accept(indexPath)
            Vibration.light.vibrate()
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
    
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {        
//        return false
//    }
}

extension DailyCalendarViewController {
    func showTodoDetail(item: Todo) {
        
    }
}

extension DailyCalendarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

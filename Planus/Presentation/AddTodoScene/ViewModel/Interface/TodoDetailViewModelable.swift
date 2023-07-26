//
//  TodoDetailViewModelable.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

enum CategoryCreateState {
    case new
    case edit(Int)
}

enum TodoCreateState {
    case new
    case edit(Todo)
    case view(Todo)
}

struct TodoDetailViewModelableInput {
    // MARK: Control Value
    var todoTitleChanged: Observable<String?>
    var categorySelected: Observable<Int?>
    var startDayChanged: Observable<Date?>
    var endDayChanged: Observable<Date?>
    var timeChanged: Observable<String?>
    var groupSelected: Observable<Int?>
    var memoChanged: Observable<String?>
    var newCategoryNameChanged: Observable<String?>
    var newCategoryColorChanged: Observable<CategoryColor?>
    var didRemoveCategory: Observable<Int>
    
    // MARK: Control Event
    var categoryEditRequested: Observable<Int>
    var startDayButtonTapped: Observable<Void>
    var endDayButtonTapped: Observable<Void>
    var categorySelectBtnTapped: Observable<Void>
    var todoSaveBtnTapped: Observable<Void>
    var todoRemoveBtnTapped: Observable<Void>
    var newCategoryAddBtnTapped: Observable<Void>
    var newCategorySaveBtnTapped: Observable<Void>
    var categorySelectPageBackBtnTapped: Observable<Void>
    var categoryCreatePageBackBtnTapped: Observable<Void>
}

struct TodoDetailViewModelableOutput {
    var categoryChanged: Observable<Category?>
    var groupChanged: Observable<GroupName?>
    var todoSaveBtnEnabled: Observable<Bool>
    var newCategorySaveBtnEnabled: Observable<Bool>
    var newCategorySaved: Observable<Void>
    var moveFromAddToSelect: Observable<Void>
    var moveFromSelectToCreate: Observable<Void>
    var moveFromCreateToSelect: Observable<Void>
    var moveFromSelectToAdd: Observable<Void>
    var removeKeyboard: Observable<Void>
    var needDismiss: Observable<Void>
}

protocol TodoDetailViewModelable: AnyObject {
    var bag: DisposeBag { get }
    
    var categoryColorList: [CategoryColor] { get set }
    var categorys: [Category] { get set }
    var groups: [GroupName] { get set }
    
    var todoCreateState: TodoCreateState { get set }
    var categoryCreatingState: CategoryCreateState { get set }
    
    var todoTitle: BehaviorSubject<String?> { get }
    var todoCategory: BehaviorSubject<Category?> { get }
    var todoStartDay: BehaviorSubject<Date?> { get }
    var todoEndDay: BehaviorSubject<Date?> { get }
    var todoTime: BehaviorSubject<String?> { get }
    var todoGroup: BehaviorSubject<GroupName?> { get }
    var todoMemo: BehaviorSubject<String?> { get }
    
    var needDismiss: PublishSubject<Void> { get }
    
    var newCategoryName: BehaviorSubject<String?> { get }
    var newCategoryColor: BehaviorSubject<CategoryColor?> { get }
    
    var groupListChanged: PublishSubject<Void> { get }
    
    var moveFromAddToSelect: PublishSubject<Void> { get }
    var moveFromSelectToCreate: PublishSubject<Void> { get }
    var moveFromCreateToSelect: PublishSubject<Void> { get }
    var moveFromSelectToAdd: PublishSubject<Void> { get }
    var needReloadCategoryList: PublishSubject<Void> { get }
    var removeKeyboard: PublishSubject<Void> { get }
    
    // 메서드는 뭐가있을까..? 카테고리 패치랑 그룹 패치
    func initFetch()
    func createTodo(todo: Todo)
    func updateTodo(todoUpdate: TodoUpdateComparator)
    func deleteTodo(todo: Todo)
    func saveNewCategory(category: Category)
    func updateCategory(category: Category)
    func deleteCategory(id: Int)
}

extension TodoDetailViewModelable {
    public func transform(input: TodoDetailViewModelableInput) -> TodoDetailViewModelableOutput {
        initFetch()
        
        input
            .todoTitleChanged
            .skip(1)
            .bind(to: todoTitle)
            .disposed(by: bag)
        
        input
            .categorySelected
            .compactMap { $0 }
            .withUnretained(self)
            .map { vm, index in
                return vm.categorys[index]
            }
            .bind(to: todoCategory)
            .disposed(by: bag)
        
        input
            .startDayChanged
            .distinctUntilChanged()
            .bind(to: todoStartDay)
            .disposed(by: bag)
        
        input
            .endDayChanged
            .distinctUntilChanged()
            .bind(to: todoEndDay)
            .disposed(by: bag)
        
        input
            .timeChanged
            .skip(1)
            .bind(to: todoTime)
            .disposed(by: bag)
        
        input
            .groupSelected
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                if let index {
                    vm.todoGroup.onNext(vm.groups[index])
                } else {
                    vm.todoGroup.onNext(nil)
                }
            })
            .disposed(by: bag)
        
        input
            .memoChanged
            .skip(1)
            .bind(to: todoMemo)
            .disposed(by: bag)
        
        input
            .newCategoryNameChanged
            .bind(to: newCategoryName)
            .disposed(by: bag)
        
        input
            .newCategoryColorChanged
            .bind(to: newCategoryColor)
            .disposed(by: bag)
        
        input
            .didRemoveCategory
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                vm.deleteCategory(id: id)
            })
            .disposed(by: bag)
        
        input
            .categoryEditRequested
            .withUnretained(self)
            .subscribe(onNext: { vm, id in
                guard let category = vm.categorys.first(where: { $0.id == id }) else { return }
                vm.categoryCreatingState = .edit(id)

                vm.newCategoryName.onNext(category.title)
                vm.newCategoryColor.onNext(category.color)
                vm.moveFromSelectToCreate.onNext(())
            })
            .disposed(by: bag)
        
        input
            .categorySelectBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.moveFromAddToSelect.onNext(())
            })
            .disposed(by: bag)
        
        input
            .todoSaveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                guard let title = try? vm.todoTitle.value(),
                      let startDate = try? vm.todoStartDay.value(),
                      let categoryId = (try? vm.todoCategory.value())?.id else { return }
                
                var endDate = startDate
                if let todoEndDay = try? vm.todoEndDay.value() {
                    endDate = todoEndDay
                }
                let memo = try? vm.todoMemo.value()
                let time = try? vm.todoTime.value()
                let groupName = try? vm.todoGroup.value()
                var todo = Todo(
                    id: nil,
                    title: title,
                    startDate: startDate,
                    endDate: endDate,
                    memo: memo,
                    groupId: groupName?.groupId,
                    categoryId: categoryId,
                    startTime: ((time?.isEmpty) ?? true) ? nil : time,
                    isCompleted: nil,
                    isGroupTodo: false
                )
                                
                switch vm.todoCreateState {
                case .new:
                    vm.createTodo(todo: todo)
                case .edit(let exTodo):
                    todo.id = exTodo.id
                    todo.isCompleted = exTodo.isCompleted
                    todo.isGroupTodo = exTodo.isGroupTodo
                    vm.updateTodo(todoUpdate: TodoUpdateComparator(before: exTodo, after: todo))
                default:
                    return
                }
                
            })
            .disposed(by: bag)
        
        input
            .todoRemoveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                switch vm.todoCreateState {
                case .edit(let exTodo):
                    vm.deleteTodo(todo: exTodo)
                default:
                    return
                }
            })
            .disposed(by: bag)
        
        input
            .newCategoryAddBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.categoryCreatingState = .new
                vm.moveFromSelectToCreate.onNext(())
            })
            .disposed(by: bag)
        
        input
            .newCategorySaveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                // 1. save current edit or creating
                guard let title = try? vm.newCategoryName.value(),
                      let color = try? vm.newCategoryColor.value() else { return }
                switch vm.categoryCreatingState {
                case .new:
                    vm.saveNewCategory(category: Category(id: nil, title: title, color: color))
                case .edit(let id):
                    vm.updateCategory(category: Category(id: id, title: title, color: color))
                }
            })
            .disposed(by: bag)
        
        input
            .categorySelectPageBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.moveFromSelectToAdd.onNext(())
            })
            .disposed(by: bag)
        
        input
            .categoryCreatePageBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.moveFromCreateToSelect.onNext(())
            })
            .disposed(by: bag)
        
        input
            .startDayButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.removeKeyboard.onNext(())
            })
            .disposed(by: bag)
        
        input
            .endDayButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.removeKeyboard.onNext(())
            })
            .disposed(by: bag)
        
        let todoSaveBtnEnabled = Observable
            .combineLatest(
                todoTitle,
                todoCategory,
                todoStartDay
            )
            .map { (title, category, startDay) in
                guard let title,
                      let category,
                      let startDay else { return false }
                
                return !title.isEmpty
            }
        
        let newCategorySaveBtnEnabled = Observable
            .combineLatest(
                newCategoryName,
                newCategoryColor
            )
            .map { (name, color) in
                guard let name,
                      let color else { return false }
                return !name.isEmpty
            }
        
        return TodoDetailViewModelableOutput(
            categoryChanged: todoCategory.asObservable(),
            groupChanged: todoGroup.asObservable(),
            todoSaveBtnEnabled: todoSaveBtnEnabled.asObservable(),
            newCategorySaveBtnEnabled: newCategorySaveBtnEnabled.asObservable(),
            newCategorySaved: needReloadCategoryList.asObservable(),
            moveFromAddToSelect: moveFromAddToSelect.asObservable(),
            moveFromSelectToCreate: moveFromSelectToCreate.asObservable(),
            moveFromCreateToSelect: moveFromCreateToSelect.asObservable(),
            moveFromSelectToAdd: moveFromSelectToAdd.asObservable(),
            removeKeyboard: removeKeyboard.asObservable(),
            needDismiss: needDismiss.asObservable()
        )
    }
}

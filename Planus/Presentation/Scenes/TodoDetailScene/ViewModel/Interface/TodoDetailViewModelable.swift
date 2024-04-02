//
//  TodoDetailViewModelable.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

struct DateRange: Equatable {
    var start: Date?
    var end: Date?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}

enum CategoryCreateState {
    case new
    case edit(Int)
}

enum TodoDetailSceneMode {
    case new // date
    case edit //todo or todoId
    case view //todo or todoId
}

enum TodoDetailSceneType {
    case memberTodo
    case socialTodo
}

struct TodoDetailViewModelActions {
    var close: (() -> Void)?
}

struct TodoDetailViewModelableInput {
    // MARK: Control Value
    var titleTextChanged: Observable<String?>
    var categorySelectedAt: Observable<Int?>
    var dayRange: Observable<DateRange>
    var timeFieldChanged: Observable<String?>
    var groupSelectedAt: Observable<Int?>
    var memoTextChanged: Observable<String?>
    var creatingCategoryNameTextChanged: Observable<String?>
    var creatingCategoryColorChanged: Observable<CategoryColor?>
    var didRemoveCategory: Observable<Int>
    
    // MARK: Control Event
    var categoryEditRequested: Observable<Int>
    var categorySelectBtnTapped: Observable<Void>
    var todoSaveBtnTapped: Observable<Void>
    var todoRemoveBtnTapped: Observable<Void>
    var newCategoryAddBtnTapped: Observable<Void>
    var newCategorySaveBtnTapped: Observable<Void>
    var categorySelectPageBackBtnTapped: Observable<Void>
    var categoryCreatePageBackBtnTapped: Observable<Void>
}

struct TodoDetailViewModelableOutput {
    var mode: TodoDetailSceneMode
    var type: TodoDetailSceneType
    var titleValueChanged: Observable<String?>
    var categoryChanged: Observable<Category?>
    var dayRangeChanged: Observable<DateRange>
    var timeValueChanged: Observable<String?>
    var groupChanged: Observable<GroupName?>
    var memoValueChanged: Observable<String?>
    var newCategorySaveBtnEnabled: Observable<Bool>
    var newCategorySaved: Observable<Void>
    var moveFromAddToSelect: Observable<Void>
    var moveFromSelectToCreate: Observable<Void>
    var moveFromCreateToSelect: Observable<Void>
    var moveFromSelectToAdd: Observable<Void>
    var removeKeyboard: Observable<Void>
    var needDismiss: Observable<Void>
    var showMessage: Observable<Message>
    var showSaveConstMessagePopUp: Observable<Void>
}

protocol TodoDetailViewModelable: AnyObject {
    
    var bag: DisposeBag { get }
    var actions: TodoDetailViewModelActions { get }
    
    var mode: TodoDetailSceneMode { get set }
    var type: TodoDetailSceneType { get }
    
    var categoryColorList: [CategoryColor] { get set }
    var categorys: [Category] { get set }
    var groups: [GroupName] { get set }
    
    var categoryCreatingState: CategoryCreateState { get set }
    
    var todoTitle: BehaviorSubject<String?> { get }
    var todoCategory: BehaviorSubject<Category?> { get }
    var todoDayRange: BehaviorSubject<DateRange> { get }
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
    var nowSaving: Bool { get set }
    var isSaveEnabled: Bool? { get set }
    
    var showMessage: PublishSubject<Message> { get }
    var showSaveConstMessagePopUp: PublishSubject<Void> { get }
    

    func initFetch()
    func saveDetail()
    func removeDetail()
    
    func saveNewCategory(category: Category)
    func updateCategory(category: Category)
    func deleteCategory(id: Int)
}

extension TodoDetailViewModelable {
    public func transform(input: TodoDetailViewModelableInput) -> TodoDetailViewModelableOutput {
        
        input
            .titleTextChanged
            .bind(to: todoTitle)
            .disposed(by: bag)
        
        input
            .categorySelectedAt
            .compactMap { $0 }
            .withUnretained(self)
            .map { vm, index in
                return vm.categorys[index]
            }
            .bind(to: todoCategory)
            .disposed(by: bag)
        
        input
            .dayRange
            .bind(to: todoDayRange)
            .disposed(by: bag)
        
        input
            .timeFieldChanged
            .bind(to: todoTime)
            .disposed(by: bag)
        
        input
            .groupSelectedAt
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
            .memoTextChanged
            .bind(to: todoMemo)
            .disposed(by: bag)
        
        input
            .creatingCategoryNameTextChanged
            .bind(to: newCategoryName)
            .disposed(by: bag)
        
        input
            .creatingCategoryColorChanged
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
                if !vm.nowSaving {
                    vm.nowSaving = true
                    guard let title = try? vm.newCategoryName.value(),
                          let color = try? vm.newCategoryColor.value() else { return }
                    switch vm.categoryCreatingState {
                    case .new:
                        vm.saveNewCategory(category: Category(id: nil, title: title, color: color))
                    case .edit(let id):
                        vm.updateCategory(category: Category(id: id, title: title, color: color))
                    }
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
        
        Observable
            .combineLatest(
                todoTitle.asObservable(),
                todoCategory.asObservable(),
                todoDayRange.asObservable(),
                todoTime.asObservable()
            )
            .map { (title, category, dayRange, time) in
                guard let title,
                      let category,
                      let _ = dayRange.start else { return false }
                var isTimeStructured = true
                if let time = time {
                    isTimeStructured = time.isEmpty || time.count == 5
                }
                
                return !title.isEmpty && isTimeStructured
            }
            .subscribe(onNext: { [weak self] isEnabled in
                self?.isSaveEnabled = isEnabled
            })
            .disposed(by: bag)
        
        input
            .todoSaveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                if vm.isSaveEnabled ?? false {
                    if !vm.nowSaving {
                        vm.nowSaving = true
                        vm.saveDetail()
                    }
                } else {
                    vm.showSaveConstMessagePopUp.onNext(())
                }
            })
            .disposed(by: bag)
        
        input
            .todoRemoveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                if !vm.nowSaving {
                    vm.nowSaving = true
                    vm.removeDetail()
                }
            })
            .disposed(by: bag)
        
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
            mode: mode,
            type: type,
            titleValueChanged: todoTitle.distinctUntilChanged().asObservable(),
            categoryChanged: todoCategory.asObservable(),
            dayRangeChanged: todoDayRange.distinctUntilChanged().asObservable(),
            timeValueChanged: todoTime.distinctUntilChanged().asObservable(),
            groupChanged: todoGroup.distinctUntilChanged().asObservable(),
            memoValueChanged: todoMemo.distinctUntilChanged().asObservable(),
            newCategorySaveBtnEnabled: newCategorySaveBtnEnabled.asObservable(),
            newCategorySaved: needReloadCategoryList.asObservable(),
            moveFromAddToSelect: moveFromAddToSelect.asObservable(),
            moveFromSelectToCreate: moveFromSelectToCreate.asObservable(),
            moveFromCreateToSelect: moveFromCreateToSelect.asObservable(),
            moveFromSelectToAdd: moveFromSelectToAdd.asObservable(),
            removeKeyboard: removeKeyboard.asObservable(),
            needDismiss: needDismiss.asObservable(),
            showMessage: showMessage.asObservable(),
            showSaveConstMessagePopUp: showSaveConstMessagePopUp.asObservable()
        )
    }
}

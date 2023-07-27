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

enum TodoDetailSceneMode {
    case new // date
    case edit //todo or todoId
    case view //todo or todoId
}

enum TodoDetailSceneType {
    case memberTodo
    case socialTodo
}

struct TodoDetailViewModelableInput {
    // MARK: Control Value
    var titleTextChanged: Observable<String?>
    var categorySelectedAt: Observable<Int?>
    var startDaySelected: Observable<Date?>
    var endDaySelected: Observable<Date?>
    var timeFieldChanged: Observable<String?>
    var groupSelectedAt: Observable<Int?>
    var memoTextChanged: Observable<String?>
    var creatingCategoryNameTextChanged: Observable<String?>
    var creatingCategoryColorChanged: Observable<CategoryColor?>
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
    
    // 여기서 모드도 전달을 할 수 있어야함......!!!
}

struct TodoDetailViewModelableOutput {
    var mode: TodoDetailSceneMode
    var type: TodoDetailSceneType
    var titleValueChanged: Observable<String?>
    var categoryChanged: Observable<Category?>
    var startDayValueChanged: Observable<Date?>
    var endDayValueChanged: Observable<Date?>
    var timeValueChanged: Observable<String?>
    var groupChanged: Observable<GroupName?>
    var memoValueChanged: Observable<String?>
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
    
    var mode: TodoDetailSceneMode { get set }
    var type: TodoDetailSceneType { get }
    
    var categoryColorList: [CategoryColor] { get set }
    var categorys: [Category] { get set }
    var groups: [GroupName] { get set }
    
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
    func saveDetail()
    func removeDetail()
    
    func saveNewCategory(category: Category)
    func updateCategory(category: Category)
    func deleteCategory(id: Int)
}

extension TodoDetailViewModelable {
    public func transform(input: TodoDetailViewModelableInput) -> TodoDetailViewModelableOutput { //여기서 양방향 바인딩 해야한다..!
        
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
            .startDaySelected
            .distinctUntilChanged()
            .bind(to: todoStartDay)
            .disposed(by: bag)
        
        input
            .endDaySelected
            .distinctUntilChanged()
            .bind(to: todoEndDay)
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
            .todoSaveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in //이부분은 구현체쪽에 구현하면 되지 않을까? 그럼 state유지하는 놈도 필요 없음
                vm.saveDetail()
            })
            .disposed(by: bag)
        
        input
            .todoRemoveBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.removeDetail()
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
            mode: mode,
            type: type,
            titleValueChanged: todoTitle.asObservable(),
            categoryChanged: todoCategory.asObservable(),
            startDayValueChanged: todoStartDay.asObservable(),
            endDayValueChanged: todoEndDay.asObservable(),
            timeValueChanged: todoTime.asObservable(),
            groupChanged: todoGroup.asObservable(),
            memoValueChanged: todoMemo.asObservable(),
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

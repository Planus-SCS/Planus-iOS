//
//  MemberTodoDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import Foundation
import RxSwift

final class MemberTodoDetailViewModel: TodoDetailViewModelable {
    
    struct Args {
        let groupList: [GroupName]
        let mode: TodoDetailSceneMode
        let todo: Todo?
        let category: Category?
        let groupName: GroupName?
        let start: Date?
        let end: Date?
    }
    
    struct Injectable {
        let actions: TodoDetailViewModelActions
        let args: Args
    }
    
    let actions: TodoDetailViewModelActions
    
    var exTodo: Todo?
    var type: TodoDetailSceneType = .memberTodo
    var mode: TodoDetailSceneMode = .new

    var bag = DisposeBag()
    
    var completionHandler: ((Todo) -> Void)?
    
    var categoryColorList: [CategoryColor] = Array(CategoryColor.allCases[0..<CategoryColor.allCases.count-1])
    
    var categorys: [Category] = []
    var groups: [GroupName] = []
    
    var categoryCreatingState: CategoryCreateState = .new
    
    var todoTitle = BehaviorSubject<String?>(value: nil)
    var todoCategory = BehaviorSubject<Category?>(value: nil)
    var todoDayRange = BehaviorSubject<DateRange>(value: DateRange())
    var todoTime = BehaviorSubject<String?>(value: nil)
    var todoGroup = BehaviorSubject<GroupName?>(value: nil)
    var todoMemo = BehaviorSubject<String?>(value: nil)
    
    var needDismiss = PublishSubject<Void>()
    
    var newCategoryName = BehaviorSubject<String?>(value: nil)
    var newCategoryColor = BehaviorSubject<CategoryColor?>(value: nil)
    
    var groupListChanged = PublishSubject<Void>()
    var showMessage = PublishSubject<Message>()
    var showSaveConstMessagePopUp = PublishSubject<Void>()
    
    let moveFromAddToSelect = PublishSubject<Void>()
    let moveFromSelectToCreate = PublishSubject<Void>()
    let moveFromCreateToSelect = PublishSubject<Void>()
    let moveFromSelectToAdd = PublishSubject<Void>()
    let needReloadCategoryList = PublishSubject<Void>()
    let removeKeyboard = PublishSubject<Void>()
    var nowSaving: Bool = false
    var isSaveEnabled: Bool?
    
    let executeWithTokenUseCase: ExecuteWithTokenUseCase
    
    let createTodoUseCase: CreateTodoUseCase
    let updateTodoUseCase: UpdateTodoUseCase
    let deleteTodoUseCase: DeleteTodoUseCase
    
    let createCategoryUseCase: CreateCategoryUseCase
    let updateCategoryUseCase: UpdateCategoryUseCase
    let deleteCategoryUseCase: DeleteCategoryUseCase
    let readCategoryUseCase: ReadCategoryListUseCase
    
    init(
        executeWithTokenUseCase: ExecuteWithTokenUseCase,
        createTodoUseCase: CreateTodoUseCase,
        updateTodoUseCase: UpdateTodoUseCase,
        deleteTodoUseCase: DeleteTodoUseCase,
        createCategoryUseCase: CreateCategoryUseCase,
        updateCategoryUseCase: UpdateCategoryUseCase,
        deleteCategoryUseCase: DeleteCategoryUseCase,
        readCategoryUseCase: ReadCategoryListUseCase,
        injectable: Injectable
    ) {
        self.executeWithTokenUseCase = executeWithTokenUseCase
        self.createTodoUseCase = createTodoUseCase
        self.updateTodoUseCase = updateTodoUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
        self.createCategoryUseCase = createCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
        self.readCategoryUseCase = readCategoryUseCase
        self.actions = injectable.actions
        
        setGroup(groupList: injectable.args.groupList)
        initMode(
            mode: injectable.args.mode,
            todo: injectable.args.todo,
            category: injectable.args.category,
            groupName: injectable.args.groupName,
            start: injectable.args.start,
            end: injectable.args.end
        )
    }
    
    func setGroup(groupList: [GroupName]) { //애도 원래 이럼 안되고 fetch해와야함!
        self.groups = groupList
    }
    
    func initMode(
        mode: TodoDetailSceneMode,
        todo: Todo? = nil,
        category: Category? = nil, 
        groupName: GroupName? = nil,
        start: Date? = nil,
        end: Date? = nil
    ) {
        self.todoGroup.onNext(groupName)
        self.todoCategory.onNext(category)
        self.mode = mode
        switch mode {
        case .new:
            self.todoDayRange.onNext(DateRange(start: start, end: (start != end) ? end : nil))
        case .edit, .view:
            guard let todo else { return }
            self.exTodo = todo
            self.todoTitle.onNext(todo.title)
            self.todoDayRange.onNext(DateRange(start: todo.startDate, end: (todo.startDate != todo.endDate) ? todo.endDate : nil))
            self.todoTime.onNext(todo.startTime)
            self.todoMemo.onNext(todo.memo)
        }
    }

    func initFetch() {
        fetchCategoryList()
        fetchGroupList()
    }
    
    func fetchCategoryList() {
        executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.readCategoryUseCase
                    .execute(token: token)
            }
            .subscribe(onSuccess: { [weak self] list in
                self?.categorys = list.filter { $0.status == .active }
                self?.needReloadCategoryList.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchGroupList() {
        
    }
    
    func saveDetail() {
        guard let title = try? todoTitle.value(),
              let dayRange = try? todoDayRange.value(),
              let startDate = dayRange.start,
              let categoryId = (try? todoCategory.value())?.id else { return }
        
        var endDate = startDate
        if let todoEndDay = dayRange.end {
            endDate = todoEndDay
        }
        let memo = try? todoMemo.value()
        let time = try? todoTime.value()
        let groupName = try? todoGroup.value()
        var todo = Todo(
            id: nil,
            title: title,
            startDate: startDate,
            endDate: endDate,
            memo: (memo?.isEmpty ?? true) ? nil : memo,
            groupId: groupName?.groupId,
            categoryId: categoryId,
            startTime: ((time?.isEmpty) ?? true) ? nil : time,
            isCompleted: nil,
            isGroupTodo: false
        )
        

        switch mode {
        case .new:
            createTodo(todo: todo)
        case .edit:
            guard let exTodo else { return }
            todo.id = exTodo.id
            todo.isCompleted = exTodo.isCompleted
            todo.isGroupTodo = exTodo.isGroupTodo
            updateTodo(todoUpdate: TodoUpdateComparator(before: exTodo, after: todo))
        default:
            return
        }
    }
    
    func removeDetail() {
        switch mode {
        case .edit:
            guard let exTodo else { return }
            deleteTodo(todo: exTodo)
        default:
            return
        }
    }
    
    func createTodo(todo: Todo) {
        executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.createTodoUseCase
                    .execute(token: token, todo: todo)
            }
            .subscribe(onSuccess: { [weak self] id in
                var todoWithId = todo
                todoWithId.id = id
                self?.nowSaving = false
                self?.needDismiss.onNext(())
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
                self?.nowSaving = false
            })
            .disposed(by: bag)
    }
    
    func updateTodo(todoUpdate: TodoUpdateComparator) {
        executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.updateTodoUseCase
                    .execute(token: token, todoUpdate: todoUpdate)
            }
            .subscribe(onSuccess: { [weak self] _ in
                self?.nowSaving = false
                self?.needDismiss.onNext(())
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.nowSaving = false
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func deleteTodo(todo: Todo) {
        executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.deleteTodoUseCase
                    .execute(token: token, todo: todo)
            }
            .subscribe(onSuccess: { [weak self] _ in
                self?.nowSaving = false
                self?.needDismiss.onNext(())
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.nowSaving = false
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }

    func saveNewCategory(category: Category) {
        executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.createCategoryUseCase
                    .execute(token: token, category: category)
            }
            .subscribe(onSuccess: { [weak self] id in
                var categoryWithId = category
                categoryWithId.id = id

                self?.categorys.append(categoryWithId)
                self?.needReloadCategoryList.onNext(())
                self?.moveFromCreateToSelect.onNext(())
                self?.nowSaving = false
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.nowSaving = false
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func updateCategory(category: Category) {
        guard let id = category.id else { return }
        
        executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.updateCategoryUseCase
                    .execute(token: token, id: id, category: category)
            }
            .subscribe(onSuccess: { [weak self] id in
                guard let index = self?.categorys.firstIndex(where: { $0.id == id }) else { return }
                self?.categorys[index] = category
                self?.needReloadCategoryList.onNext(())
                self?.moveFromCreateToSelect.onNext(())
                self?.nowSaving = false
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.nowSaving = false
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func deleteCategory(id: Int) {
        executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.deleteCategoryUseCase
                    .execute(token: token, id: id)
            }
            .subscribe(onSuccess: { [weak self] in
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
}

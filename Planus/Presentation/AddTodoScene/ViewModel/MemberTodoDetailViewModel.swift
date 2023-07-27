//
//  MemberTodoDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import Foundation
import RxSwift

final class MemberTodoDetailViewModel: TodoDetailViewModelable {

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
    var todoStartDay = BehaviorSubject<Date?>(value: nil)
    var todoEndDay = BehaviorSubject<Date?>(value: nil)
    var todoTime = BehaviorSubject<String?>(value: nil)
    var todoGroup = BehaviorSubject<GroupName?>(value: nil)
    var todoMemo = BehaviorSubject<String?>(value: nil)
    
    var needDismiss = PublishSubject<Void>()
    
    var newCategoryName = BehaviorSubject<String?>(value: nil)
    var newCategoryColor = BehaviorSubject<CategoryColor?>(value: nil)
    
    var groupListChanged = PublishSubject<Void>()
    
    let moveFromAddToSelect = PublishSubject<Void>()
    let moveFromSelectToCreate = PublishSubject<Void>()
    let moveFromCreateToSelect = PublishSubject<Void>()
    let moveFromSelectToAdd = PublishSubject<Void>()
    let needReloadCategoryList = PublishSubject<Void>()
    let removeKeyboard = PublishSubject<Void>()
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    
    var createTodoUseCase: CreateTodoUseCase
    var updateTodoUseCase: UpdateTodoUseCase
    var deleteTodoUseCase: DeleteTodoUseCase
    
    var createCategoryUseCase: CreateCategoryUseCase
    var updateCategoryUseCase: UpdateCategoryUseCase
    var deleteCategoryUseCase: DeleteCategoryUseCase
    var readCategoryUseCase: ReadCategoryListUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        createTodoUseCase: CreateTodoUseCase,
        updateTodoUseCase: UpdateTodoUseCase,
        deleteTodoUseCase: DeleteTodoUseCase,
        createCategoryUseCase: CreateCategoryUseCase,
        updateCategoryUseCase: UpdateCategoryUseCase,
        deleteCategoryUseCase: DeleteCategoryUseCase,
        readCategoryUseCase: ReadCategoryListUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.createTodoUseCase = createTodoUseCase
        self.updateTodoUseCase = updateTodoUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
        self.createCategoryUseCase = createCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
        self.readCategoryUseCase = readCategoryUseCase
    }
    
    func setGroup(groupList: [GroupName]) { //애도 원래 이럼 안되고 fetch해와야함!
        self.groups = groupList
    }
    
    func initMode(mode: TodoDetailSceneMode, todo: Todo? = nil, category: Category? = nil, groupName: GroupName? = nil, start: Date? = nil, end: Date? = nil) { //여기서 new는 date, 아님 투두임. 하씨,,, 이거 어케 안되냐..?
        self.mode = mode
        switch mode {
        case .new:
            self.todoStartDay.onNext(start)
            self.todoEndDay.onNext((start != end) ? end : nil)
        case .edit, .view:
            guard let todo else { return }
            print("category ID: ", todo.categoryId)
            self.exTodo = todo
            self.todoCategory.onNext(category)
            self.todoGroup.onNext(groupName)
        }
    }

    func initFetch() { //여기서 exTodo가 있으면 넣어줘야함..!!!
        switch mode {
        case .edit, .view:
            guard let exTodo else { return }
            self.todoTitle.onNext(exTodo.title)
            self.todoStartDay.onNext(exTodo.startDate)
            self.todoEndDay.onNext((exTodo.startDate != exTodo.endDate) ? exTodo.endDate : nil)
            self.todoTime.onNext(exTodo.startTime)
            self.todoMemo.onNext(exTodo.memo)
        default:
            break
        }
        fetchCategoryList()
        fetchGroupList()
    }
    
    func fetchCategoryList() {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Category]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.readCategoryUseCase
                    .execute(token: token)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
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
              let startDate = try? todoStartDay.value(),
              let categoryId = (try? todoCategory.value())?.id else { return }
        var endDate = startDate
        if let todoEndDay = try? todoEndDay.value() {
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
            memo: memo,
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
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.createTodoUseCase
                    .execute(token: token, todo: todo)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] id in
                var todoWithId = todo
                todoWithId.id = id
                self?.needDismiss.onNext(())
            })
            .disposed(by: bag)
    }
    
    func updateTodo(todoUpdate: TodoUpdateComparator) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.updateTodoUseCase
                    .execute(token: token, todoUpdate: todoUpdate)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.needDismiss.onNext(())
            })
            .disposed(by: bag)
    }
    
    func deleteTodo(todo: Todo) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.deleteTodoUseCase
                    .execute(token: token, todo: todo)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.needDismiss.onNext(())
            })
            .disposed(by: bag)
    }

    func saveNewCategory(category: Category) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.createCategoryUseCase
                    .execute(token: token, category: category)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] id in
                var categoryWithId = category
                categoryWithId.id = id

                self?.categorys.append(categoryWithId)
                self?.needReloadCategoryList.onNext(())
                self?.moveFromCreateToSelect.onNext(())
            })
            .disposed(by: bag)
    }
    
    func updateCategory(category: Category) {
        guard let id = category.id else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.updateCategoryUseCase
                    .execute(token: token, id: id, category: category)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] id in
                guard let index = self?.categorys.firstIndex(where: { $0.id == id }) else { return }
                self?.categorys[index] = category
                self?.needReloadCategoryList.onNext(())
                self?.moveFromCreateToSelect.onNext(())
            }, onFailure: { error in
                print(error)
            })
            .disposed(by: bag)
    }
    
    func deleteCategory(id: Int) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.deleteCategoryUseCase
                    .execute(token: token, id: id)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] in
                print("removed!!")
            })
            .disposed(by: bag)
    }
}

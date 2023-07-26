//
//  MemberTodoDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import Foundation
import RxSwift

final class MemberTodoDetailViewModel: TodoDetailViewModelable {
    var bag = DisposeBag()
    
    var completionHandler: ((Todo) -> Void)?
    
    var categoryColorList: [CategoryColor] = Array(CategoryColor.allCases[0..<CategoryColor.allCases.count-1])
    
    var categorys: [Category] = []
    var groups: [GroupName] = []
    
    var todoCreateState: TodoCreateState = .new
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
    
    func setGroup(groupList: [GroupName]) {
        self.groups = groupList
    }
    
    func setForEdit(todo: Todo, category: Category, groupName: GroupName?) {
        guard let id = todo.id else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy.MM.dd"
        self.todoTitle.onNext(todo.title)
        self.todoCategory.onNext(category)
        self.todoGroup.onNext(groupName)
        self.todoStartDay.onNext(todo.startDate)
        // FIXME: endDate는 설정 안함 아직
        self.todoTime.onNext(todo.startTime)
        self.todoMemo.onNext(todo.memo)
        self.todoCreateState = .edit(todo)
    }
    
    func setForOthers(todo: Todo, category: Category, groupName: GroupName?) {
        guard let id = todo.id else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy.MM.dd"
        self.todoTitle.onNext(todo.title)
        self.todoCategory.onNext(category)
        self.todoStartDay.onNext(todo.startDate)
        // FIXME: endDate는 설정 안함 아직
        self.todoTime.onNext(todo.startTime)
        self.todoMemo.onNext(todo.memo)
        self.todoCreateState = .view(todo)
        self.todoGroup.onNext(groupName)
    }
    
    func initFetch() {
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

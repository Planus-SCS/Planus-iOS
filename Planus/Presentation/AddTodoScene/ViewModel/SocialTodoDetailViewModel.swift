//
//  SocialTodoDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

struct SocialTodoDetail {
    var groupId: Int?
    var memberId: Int?
    var todoId: Int?
}

final class SocialTodoDetailViewModel: TodoDetailViewModelable {
    enum Mode {
        case new(SocialTodoDetail)
        case edit(SocialTodoDetail) //
        case view(SocialTodoDetail) //그룹 투두인지 다른놈 투두인지 알아야함
    }
    
    var mode: Mode = .new(SocialTodoDetail())
    
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
    
    var fetchGroupMemberTodoDetailUseCase: FetchGroupMemberTodoDetailUseCase
    
    var fetchGroupTodoDetailUseCase: FetchGroupTodoDetailUseCase
    var createGroupTodoUseCase: CreateGroupTodoUseCase
    var updateGroupTodoUseCase: UpdateGroupTodoUseCase
    var deleteGroupTodoUseCase: DeleteGroupTodoUseCase
    
    var createGroupCategoryUseCase: CreateGroupCategoryUseCase
    var updateGroupCategoryUseCase: UpdateGroupCategoryUseCase
    var deleteGroupCategoryUseCase: DeleteGroupCategoryUseCase
    var fetchGroupCategorysUseCase: FetchGroupCategorysUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchGroupMemberTodoDetailUseCase: FetchGroupMemberTodoDetailUseCase,
        fetchGroupTodoDetailUseCase: FetchGroupTodoDetailUseCase,
        createGroupTodoUseCase: CreateGroupTodoUseCase,
        updateGroupTodoUseCase: UpdateGroupTodoUseCase,
        deleteGroupTodoUseCase: DeleteGroupTodoUseCase,
        createGroupCategoryUseCase: CreateGroupCategoryUseCase,
        updateGroupCategoryUseCase: UpdateGroupCategoryUseCase,
        deleteGroupCategoryUseCase: DeleteGroupCategoryUseCase,
        fetchGroupCategorysUseCase: FetchGroupCategorysUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchGroupMemberTodoDetailUseCase = fetchGroupMemberTodoDetailUseCase
        self.fetchGroupTodoDetailUseCase = fetchGroupTodoDetailUseCase
        self.createGroupTodoUseCase = createGroupTodoUseCase
        self.updateGroupTodoUseCase = updateGroupTodoUseCase
        self.deleteGroupTodoUseCase = deleteGroupTodoUseCase
        self.createGroupCategoryUseCase = createGroupCategoryUseCase
        self.updateGroupCategoryUseCase = updateGroupCategoryUseCase
        self.deleteGroupCategoryUseCase = deleteGroupCategoryUseCase
        self.fetchGroupCategorysUseCase = fetchGroupCategorysUseCase
    }
    
    func setGroup(groupList: [GroupName]) {
        self.groups = groupList
    }
    
    func initMode(mode: Mode) {
        self.mode = mode
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
        case .new(let info):
            guard let groupId = info.groupId else { return }
            createTodo(groupId: groupId, todo: todo)
        case .edit(let info):
            guard let groupId = info.groupId,
                  let todoId = info.todoId else { return }
            todo.id = todoId
            updateTodo(groupId: groupId, todoId: todoId, todo: todo)
        default:
            return
        }
    }
    
    func createTodo(groupId: Int, todo: Todo) {
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
    
    func updateTodo(groupId: Int, todoId: Int, todo: Todo) {
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

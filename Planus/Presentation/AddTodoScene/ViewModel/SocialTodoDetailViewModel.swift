//
//  SocialTodoDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

struct SocialTodoInfo { //그룹투두 또한 조회만 되기도 하고 주인장은 수정이 되기도 한다,,,
    var group: GroupName?
    var memberId: Int?
    var todoId: Int?
}

final class SocialTodoDetailViewModel: TodoDetailViewModelable {

    var info: SocialTodoInfo?
    
    var type: TodoDetailSceneType = .socialTodo
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
    var createGroupTodoUseCase: CreateGroupTodoUseCase // 업댓 필요!
    var updateGroupTodoUseCase: UpdateGroupTodoUseCase  // 업댓 필요!
    var deleteGroupTodoUseCase: DeleteGroupTodoUseCase   // 업댓 필요!
    
    var createGroupCategoryUseCase: CreateGroupCategoryUseCase
    var updateGroupCategoryUseCase: UpdateGroupCategoryUseCase  // 업댓 필요!!
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
    
    func initMode(mode: TodoDetailSceneMode, info: SocialTodoInfo, date: Date? = nil) {
        self.mode = mode
        self.info = info
        self.todoDayRange.onNext(DateRange(start: date))
    }
    
    func initFetch() {
        switch mode {
        case .new:
            guard let group = info?.group else { return }
            self.todoGroup.onNext(group)
            fetchCategoryList(groupId: group.groupId)
        case .edit:
            guard let group = info?.group,
                  let todoId = info?.todoId else { return }
            
            fetchGroupTodoDetail(groupId: group.groupId, todoId: todoId)
            fetchCategoryList(groupId: group.groupId)
        case .view:
            guard let group = info?.group,
                  let todoId = info?.todoId else { return }
            
            if let memberId = info?.memberId {
                fetchGroupMemberTodoDetail(groupId: group.groupId, memberId: memberId, todoId: todoId)
            } else {
                fetchGroupTodoDetail(groupId: group.groupId, todoId: todoId)
            }
            return
        }
    }
    
    func fetchGroupTodoDetail(groupId: Int, todoId: Int) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<SocialTodoDetail> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchGroupTodoDetailUseCase
                    .execute(token: token, groupId: groupId, todoId: todoId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] todo in
                self?.todoTitle.onNext(todo.title)
                self?.todoCategory.onNext(Category(title: todo.todoCategory.name, color: todo.todoCategory.color))
                self?.todoDayRange.onNext(DateRange(start: todo.startDate, end: (todo.startDate != todo.endDate) ? todo.endDate : nil))
                self?.todoTime.onNext(todo.startTime)
                self?.todoGroup.onNext(GroupName(groupId: groupId, groupName: todo.groupName))
                self?.todoMemo.onNext(todo.description)
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func fetchGroupMemberTodoDetail(groupId: Int, memberId: Int, todoId: Int) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<SocialTodoDetail> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchGroupMemberTodoDetailUseCase
                    .execute(token: token, groupId: groupId, memberId: memberId, todoId: todoId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] todo in
                self?.todoTitle.onNext(todo.title)
                self?.todoCategory.onNext(Category(id: todo.todoCategory.id, title: todo.todoCategory.name, color: todo.todoCategory.color))
                self?.todoDayRange.onNext(DateRange(start: todo.startDate, end: (todo.startDate != todo.endDate) ? todo.endDate : nil))
                self?.todoGroup.onNext(GroupName(groupId: groupId, groupName: todo.groupName))
                self?.todoMemo.onNext(todo.description)
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func fetchCategoryList(groupId: Int) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[Category]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchGroupCategorysUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.categorys = list.filter { $0.status == .active }
                self?.needReloadCategoryList.onNext(())
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }

    func saveDetail() {
        guard let title = try? todoTitle.value(),
              let dateRange = try? todoDayRange.value(),
              let startDate = dateRange.start,
              let categoryId = (try? todoCategory.value())?.id else { return }
        
        var endDate = startDate
        if let todoEndDay = dateRange.end {
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
            guard let groupId = info?.group?.groupId else { return }
            createTodo(groupId: groupId, todo: todo)
        case .edit:
            guard let groupId = info?.group?.groupId,
                  let todoId = info?.todoId else { return }
            todo.id = todoId
            updateTodo(groupId: groupId, todoId: todoId, todo: todo)
        default:
            return
        }
    }
    
    func removeDetail() {
        switch mode {
        case .edit:
            guard let groupId = info?.group?.groupId,
                  let todoId = info?.todoId else { return }
            deleteTodo(groupId: groupId, todoId: todoId)
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
                return self.createGroupTodoUseCase
                    .execute(token: token, groupId: groupId, todo: todo)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] id in
                var todoWithId = todo
                todoWithId.id = id
                self?.needDismiss.onNext(())
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func updateTodo(groupId: Int, todoId: Int, todo: Todo) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.updateGroupTodoUseCase
                    .execute(token: token, groupId: groupId, todoId: todoId, todo: todo)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.needDismiss.onNext(())
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func deleteTodo(groupId: Int, todoId: Int) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.deleteGroupTodoUseCase
                    .execute(token: token, groupId: groupId, todoId: todoId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.needDismiss.onNext(())
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }

    func saveNewCategory(category: Category) {
        var groupId: Int
        switch mode {
        case .new, .edit:
            guard let infoGroupId = info?.group?.groupId else { return }
            groupId = infoGroupId
        default: return
        }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.createGroupCategoryUseCase
                    .execute(token: token, groupId: groupId, category: category)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] id in
                var categoryWithId = category
                categoryWithId.id = id

                self?.categorys.append(categoryWithId)
                self?.needReloadCategoryList.onNext(())
                self?.moveFromCreateToSelect.onNext(())
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func updateCategory(category: Category) {
        guard let id = category.id else { return }
        
        var groupId: Int
        switch mode {
        case .new, .edit:
            guard let infoGroupId = info?.group?.groupId else { return }
            groupId = infoGroupId
        default: return
        }
        
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.updateGroupCategoryUseCase
                    .execute(token: token, groupId: groupId, categoryId: id, category: category)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] id in
                guard let index = self?.categorys.firstIndex(where: { $0.id == id }) else { return }
                self?.categorys[index] = category
                self?.needReloadCategoryList.onNext(())
                self?.moveFromCreateToSelect.onNext(())
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
    
    func deleteCategory(id: Int) {
        var groupId: Int
        switch mode {
        case .new, .edit:
            guard let infoGroupId = info?.group?.groupId else { return }
            groupId = infoGroupId
        default: return
        }
        
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.deleteGroupCategoryUseCase
                    .execute(token: token, groupId: groupId, categoryId: id)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
}

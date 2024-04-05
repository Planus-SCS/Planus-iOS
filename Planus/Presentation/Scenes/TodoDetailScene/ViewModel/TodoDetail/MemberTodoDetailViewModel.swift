//
//  MemberTodoDetailViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 4/5/24.
//

import Foundation
import RxSwift

final class MemberTodoDetailViewModel: TodoDetailViewModelable {

    struct UseCases {
        let executeWithTokenUseCase: ExecuteWithTokenUseCase
        let fetchGroupMemberTodoDetailUseCase: FetchGroupMemberTodoDetailUseCase
    }
    
    struct Actions {
        var dismiss: (() -> Void)?
    }
    
    struct Args {
        var group: GroupName
        var memberId: Int
        var todoId: Int
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    let useCases: UseCases
    let actions: Actions
        
    let group: GroupName
    let memberId: Int
    let todoId: Int
        
    let bag = DisposeBag()
            
    var groups: [GroupName] = []
        
    var todoTitle = BehaviorSubject<String?>(value: nil)
    var todoCategory = BehaviorSubject<Category?>(value: nil)
    var todoDayRange = BehaviorSubject<DateRange>(value: DateRange())
    var todoTime = BehaviorSubject<String?>(value: nil)
    var todoGroup = BehaviorSubject<GroupName?>(value: nil)
    var todoMemo = BehaviorSubject<String?>(value: nil)
    
    var dismissRequired = PublishSubject<Void>()
    
    var groupListChanged = PublishSubject<Void>()
    var showMessage = PublishSubject<Message>()
    var showSaveConstMessagePopUp = PublishSubject<Void>()
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.group = injectable.args.group
        self.todoId = injectable.args.todoId
        self.memberId = injectable.args.memberId
        self.groups.append(injectable.args.group)
    }
    
    func fetch() {
        fetchGroupMemberTodoDetail(groupId: group.groupId, memberId: memberId, todoId: todoId)
    }
    
    func fetchGroupMemberTodoDetail(groupId: Int, memberId: Int, todoId: Int) {
        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token in
                return self?.useCases.fetchGroupMemberTodoDetailUseCase
                    .execute(token: token, groupId: groupId, memberId: memberId, todoId: todoId)
            }
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

    func dismiss() {
        actions.dismiss?()
    }
}

extension MemberTodoDetailViewModel {
    func transform(input: Input) -> Output {
        
        let groupChangedToIndex = todoGroup
            .distinctUntilChanged()
            .withUnretained(self)
            .map { vm, group -> Int? in
                guard let group else { return nil }
                return vm.groups.firstIndex(of: group)
            }
        
        input
            .needDismiss
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.dismiss?()
            })
            .disposed(by: bag)
        
        return Output(
            mode: .viewable,
            titleValueChanged: todoTitle.distinctUntilChanged().asObservable(),
            categoryChanged: todoCategory.asObservable(),
            dayRangeChanged: todoDayRange.distinctUntilChanged().asObservable(),
            timeValueChanged: todoTime.distinctUntilChanged().asObservable(),
            groupChangedToIndex: groupChangedToIndex,
            memoValueChanged: todoMemo.distinctUntilChanged().asObservable(),
            showMessage: showMessage.asObservable(),
            showSaveConstMessagePopUp: showSaveConstMessagePopUp.asObservable(),
            dismissRequired: dismissRequired.asObservable()
        )
    }
}

//
//  GroupDailyCalendarViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import Foundation
import RxSwift

final class GroupDailyCalendarViewModel: DailyCalendarViewModelable {
    
    struct UseCases {
        var executeWithTokenUseCase: ExecuteWithTokenUseCase
        
        var fetchGroupDailyTodoListUseCase: FetchGroupDailyCalendarUseCase
        
        let createGroupTodoUseCase: CreateGroupTodoUseCase
        let updateGroupTodoUseCase: UpdateGroupTodoUseCase
        let deleteGroupTodoUseCase: DeleteGroupTodoUseCase
        let updateGroupCategoryUseCase: UpdateGroupCategoryUseCase
    }
    
    struct Actions {
        let showTodoDetail: ((GroupTodoDetailViewModel.Args) -> Void)?
        let finishScene: (() -> Void)?
    }
    
    struct Args {
        let group: GroupName
        let isLeader: Bool
        let date: Date
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    private var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    let group: GroupName
    let isLeader: Bool
    let currentDate: Date

    var todos = [[SocialTodoDaily]](repeating: [SocialTodoDaily](), count: DailyCalendarTodoType.allCases.count)
    var todoViewModels = [[TodoDailyViewModel]](repeating: [TodoDailyViewModel](), count: DailyCalendarTodoType.allCases.count)
    
    var currentDateText: String?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter
    }()
    
    private let nowFetchLoading = BehaviorSubject<Void?>(value: nil)
    private let didFetchTodoList = BehaviorSubject<Void?>(value: nil)
    private let showAlert = PublishSubject<Message>()
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.group = injectable.args.group
        self.isLeader = injectable.args.isLeader
        self.currentDate = injectable.args.date
        
        self.currentDateText = dateFormatter.string(from: currentDate)
    }
    
    func transform(input: Input) -> Output {
        bindUseCase()
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchGroupTodoList()
            })
            .disposed(by: bag)
        
        input
            .addTodoTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.showTodoDetail?(
                    GroupTodoDetailViewModel.Args(
                        type: .new(vm.currentDate),
                        group: vm.group
                    )
                )
            })
            .disposed(by: bag)
        
        input
            .todoSelectedAt
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                let todoId: Int = vm.todoViewModels[indexPath.section][indexPath.item].todoId
                let args = GroupTodoDetailViewModel.Args(type: vm.isLeader ? .edit(todoId) : .view(todoId), group: vm.group)
                
                vm.actions.showTodoDetail?(args)
            })
            .disposed(by: bag)
        
        input
            .viewDidDismissed
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.finishScene?()
            })
            .disposed(by: bag)
        
        return Output(
            currentDateText: currentDateText,
            nowLoading: nowFetchLoading.asObservable(),
            needReloadData: didFetchTodoList.asObservable(),
            showAlert: showAlert.asObservable(),
            mode: isLeader ? .editable : .viewable
        )
    }
}

// MARK: - bind useCases
private extension GroupDailyCalendarViewModel {
    func bindUseCase() {
        useCases
            .createGroupTodoUseCase
            .didCreateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.group.groupId == todo.groupId else { return }
                vm.fetchGroupTodoList()
            })
            .disposed(by: bag)
        
        useCases
            .updateGroupTodoUseCase
            .didUpdateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.group.groupId == todo.groupId else { return }
                vm.fetchGroupTodoList()
            })
            .disposed(by: bag)
        
        useCases
            .deleteGroupTodoUseCase
            .didDeleteGroupTodoWithIds
            .withUnretained(self)
            .subscribe(onNext: { vm, ids in
                guard vm.group.groupId == ids.groupId else { return }
                vm.fetchGroupTodoList()
            })
            .disposed(by: bag)
        
        useCases
            .updateGroupCategoryUseCase
            .didUpdateCategoryWithGroupId
            .withUnretained(self)
            .subscribe(onNext: { vm, categoryWithGroupId in
                guard vm.group.groupId == categoryWithGroupId.groupId else { return }
                vm.fetchGroupTodoList()
            })
            .disposed(by: bag)
        
    }
}

private extension GroupDailyCalendarViewModel {
    func fetchGroupTodoList() {
        nowFetchLoading.onNext(())

        useCases
            .executeWithTokenUseCase
            .execute() { [weak self] token -> Single<[[SocialTodoDaily]]>? in
                guard let self else { return nil }
                return self.useCases.fetchGroupDailyTodoListUseCase
                    .execute(token: token, groupId: self.group.groupId, date: self.currentDate)
            }
            .subscribe(onSuccess: { [weak self] list in
                self?.todos = list
                self?.prepareViewModel(todos: list)
                self?.didFetchTodoList.onNext(())
            })
            .disposed(by: bag)
    }
    
    func prepareViewModel(todos: [[SocialTodoDaily]]) {
        self.todoViewModels = todos.map { list in
            return list.map { item in
                return item.toViewModel()
            }
        }
    }

}

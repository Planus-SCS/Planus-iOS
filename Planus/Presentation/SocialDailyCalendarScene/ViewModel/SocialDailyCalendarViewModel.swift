//
//  SocialTodoDailyViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

enum SocialDailyCalendarViewModelType {
    case member(id: Int)
    case group(isLeader: Bool)
}

class SocialDailyCalendarViewModel: ViewModel {
    
    struct UseCases {
        var getTokenUseCase: GetTokenUseCase
        var refreshTokenUseCase: RefreshTokenUseCase
        
        var fetchGroupDailyTodoListUseCase: FetchGroupDailyCalendarUseCase
        var fetchMemberDailyCalendarUseCase: FetchGroupMemberDailyCalendarUseCase
        
        let createGroupTodoUseCase: CreateGroupTodoUseCase
        let updateGroupTodoUseCase: UpdateGroupTodoUseCase
        let deleteGroupTodoUseCase: DeleteGroupTodoUseCase
        let updateGroupCategoryUseCase: UpdateGroupCategoryUseCase
    }
    
    struct Actions {
        let showSocialTodoDetail: ((SocialTodoDetailViewModel.Args) -> Void)?
        let finishScene: (() -> Void)?
    }
    
    struct Args {
        let group: GroupName
        let type: SocialDailyCalendarViewModelType
        let date: Date
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions

    let group: GroupName
    let type: SocialDailyCalendarViewModelType
    let currentDate: Date
    
    var scheduledTodoList: [SocialTodoDaily]?
    var unscheduledTodoList: [SocialTodoDaily]?
        
    var currentDateText: String?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter
    }()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var addTodoTapped: Observable<Void>
        var didSelectTodoAt: Observable<IndexPath>
    }
    
    struct Output {
        var currentDateText: String?
        var socialType: SocialDailyCalendarViewModelType?
        var nowFetchLoading: Observable<Void?>
        var didFetchTodoList: Observable<Void?>
    }
    
    var nowFetchLoading = BehaviorSubject<Void?>(value: nil)
    var didFetchTodoList = BehaviorSubject<Void?>(value: nil)
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.group = injectable.args.group
        self.type = injectable.args.type
        self.currentDate = injectable.args.date
        
        self.currentDateText = dateFormatter.string(from: currentDate)
    }
    
    func transform(input: Input) -> Output {

        if case .group(isLeader: let isLeader) = type,
           isLeader {
            bindUseCase()
        }
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchTodoList()
            })
            .disposed(by: bag)
        
        input
            .addTodoTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.showSocialTodoDetail?(
                    SocialTodoDetailViewModel.Args(
                        mode: .new,
                        info: SocialTodoInfo(group: vm.group),
                        date: vm.currentDate
                    )
                )
            })
            .disposed(by: bag)
        
        input
            .didSelectTodoAt
            .withUnretained(self)
            .subscribe(onNext: { vm, indexPath in
                print("fuck")
                var todoId: Int?
                switch indexPath.section {
                case 0:
                    if vm.scheduledTodoList?.count != 0 {
                        todoId = vm.scheduledTodoList?[indexPath.item].todoId
                    }
                case 1:
                    if vm.unscheduledTodoList?.count != 0 {
                        todoId = vm.unscheduledTodoList?[indexPath.item].todoId
                    }
                default:
                    return
                }
                guard let todoId else { return }
                
                var args: SocialTodoDetailViewModel.Args
                switch vm.type {
                case .member(let id): //애는 무적권 조회만
                    args = SocialTodoDetailViewModel.Args(
                        mode: .view,
                        info: SocialTodoInfo(group: vm.group, memberId: id, todoId: todoId),
                        date: nil
                    )
                case .group(let isLeader): //애는 edit
                    args = SocialTodoDetailViewModel.Args(
                        mode: isLeader ? .edit : .view,
                        info: SocialTodoInfo(group: vm.group, todoId: todoId),
                        date: nil
                    )
                }
                
                vm.actions.showSocialTodoDetail?(args)
            })
            .disposed(by: bag)
        
        return Output(
            currentDateText: currentDateText,
            socialType: type,
            nowFetchLoading: nowFetchLoading.asObservable(),
            didFetchTodoList: didFetchTodoList.asObservable()
        )
    }
 
    func bindUseCase() {
        useCases
            .createGroupTodoUseCase
            .didCreateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.group.groupId == todo.groupId else { return }
                vm.fetchTodoList()
            })
            .disposed(by: bag)
        
        useCases
            .updateGroupTodoUseCase
            .didUpdateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.group.groupId == todo.groupId else { return }
                vm.fetchTodoList()
            })
            .disposed(by: bag)
        
        useCases
            .deleteGroupTodoUseCase
            .didDeleteGroupTodoWithIds
            .withUnretained(self)
            .subscribe(onNext: { vm, ids in
                guard vm.group.groupId == ids.groupId else { return }
                vm.fetchTodoList()
            })
            .disposed(by: bag)
        
        useCases
            .updateGroupCategoryUseCase
            .didUpdateCategoryWithGroupId
            .withUnretained(self)
            .subscribe(onNext: { vm, categoryWithGroupId in
                guard vm.group.groupId == categoryWithGroupId.groupId else { return }
                vm.fetchTodoList()
            })
            .disposed(by: bag)

    }
    
    func fetchTodoList() {
        switch type {
        case .group(let _):
            fetchGroupTodoList()
            return
        case .member(let id):
            fetchMemberTodoList(memberId: id)
            return
        }
    }
    
    
    func fetchMemberTodoList(memberId: Int) {
        nowFetchLoading.onNext(())

        useCases
            .getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[[SocialTodoDaily]]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.fetchMemberDailyCalendarUseCase
                    .execute(token: token, groupId: group.groupId, memberId: memberId, date: currentDate)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.scheduledTodoList = list[0]
                self?.unscheduledTodoList = list[1]
                self?.didFetchTodoList.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchGroupTodoList() {
        nowFetchLoading.onNext(())

        useCases
            .getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[[SocialTodoDaily]]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.fetchGroupDailyTodoListUseCase
                    .execute(token: token, groupId: group.groupId, date: currentDate)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.scheduledTodoList = list[0]
                self?.unscheduledTodoList = list[1]
                self?.didFetchTodoList.onNext(())
            })
            .disposed(by: bag)
    }

}

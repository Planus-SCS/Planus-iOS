//
//  SocialTodoDailyViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

enum SocialTodoViewModelType {
    case member(id: Int)
    case group(isLeader: Bool)
}

class SocialTodoDailyViewModel: ViewModel {
    
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
        let showSocialTodoDetail: (() -> Void)?
        let finishScene: (() -> Void)?
    }
    
    struct Args {
        let group: GroupName
        let type: SocialTodoViewModelType
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
    let type: SocialTodoViewModelType
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
    }
    
    struct Output {
        var currentDateText: String?
        var socialType: SocialTodoViewModelType?
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
        
        return Output(
            currentDateText: currentDateText,
            socialType: type,
            nowFetchLoading: nowFetchLoading.asObservable(),
            didFetchTodoList: didFetchTodoList.asObservable()
        )
    }
    
    // 여기선 굳이 카테고리 생성,수정,삭제에 따라서 패치하지말고 그냥 다시 받아오자!
    // 투두도 생성, 수정, 삭제에 따라서 그냥 다시 받아올까? 아님 어카지?(카테고리를 생성하고 그걸로 투두 생성할 경우에... 가 아니라 가능하구나 애는..! ㅇㅋ!
    
    func bindUseCase() { //이건 그냥 바인딩 하면 안됨
        useCases
            .createGroupTodoUseCase //삽입하고 리로드 or 다시 받기.. 뭐가 좋을랑가 -> 걍 다시받자!
            .didCreateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.group.groupId == todo.groupId else { return }
                vm.fetchTodoList()
            })
            .disposed(by: bag)
        
        useCases
            .updateGroupTodoUseCase // 삭제하고 다시넣기,,, 걍 다시받는게 편하겠지 아무래도?
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

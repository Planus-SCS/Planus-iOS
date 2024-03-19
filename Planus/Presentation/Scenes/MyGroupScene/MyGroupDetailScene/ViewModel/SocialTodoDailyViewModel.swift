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

class SocialTodoDailyViewModel {
    var bag = DisposeBag()

    var group: GroupName?
    
    var scheduledTodoList: [SocialTodoDaily]?
    var unscheduledTodoList: [SocialTodoDaily]?
        
    var currentDate: Date?
    var currentDateText: String?
    
    var type: SocialTodoViewModelType?
    
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

    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    
    var fetchGroupDailyTodoListUseCase: FetchGroupDailyCalendarUseCase
    var fetchMemberDailyCalendarUseCase: FetchGroupMemberDailyCalendarUseCase
    
    let createGroupTodoUseCase: CreateGroupTodoUseCase
    let updateGroupTodoUseCase: UpdateGroupTodoUseCase
    let deleteGroupTodoUseCase: DeleteGroupTodoUseCase
    let updateGroupCategoryUseCase: UpdateGroupCategoryUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchGroupDailyTodoListUseCase: FetchGroupDailyCalendarUseCase,
        fetchMemberDailyCalendarUseCase: FetchGroupMemberDailyCalendarUseCase,
        createGroupTodoUseCase: CreateGroupTodoUseCase,
        updateGroupTodoUseCase: UpdateGroupTodoUseCase,
        deleteGroupTodoUseCase: DeleteGroupTodoUseCase,
        updateGroupCategoryUseCase: UpdateGroupCategoryUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchGroupDailyTodoListUseCase = fetchGroupDailyTodoListUseCase
        self.fetchMemberDailyCalendarUseCase = fetchMemberDailyCalendarUseCase
        
        self.createGroupTodoUseCase = createGroupTodoUseCase
        self.updateGroupTodoUseCase = updateGroupTodoUseCase
        self.deleteGroupTodoUseCase = deleteGroupTodoUseCase
        self.updateGroupCategoryUseCase = updateGroupCategoryUseCase
    }
    
    func setGroup(group: GroupName, type: SocialTodoViewModelType, date: Date) {
        self.group = group
        self.type = type
        self.currentDate = date
        self.currentDateText = dateFormatter.string(from: date)
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
        createGroupTodoUseCase //삽입하고 리로드 or 다시 받기.. 뭐가 좋을랑가 -> 걍 다시받자!
            .didCreateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.group?.groupId == todo.groupId else { return }
                vm.fetchTodoList()
            })
            .disposed(by: bag)
        
        updateGroupTodoUseCase // 삭제하고 다시넣기,,, 걍 다시받는게 편하겠지 아무래도?
            .didUpdateGroupTodo
            .withUnretained(self)
            .subscribe(onNext: { vm, todo in
                guard vm.group?.groupId == todo.groupId else { return }
                vm.fetchTodoList()
            })
            .disposed(by: bag)
        
        deleteGroupTodoUseCase
            .didDeleteGroupTodoWithIds
            .withUnretained(self)
            .subscribe(onNext: { vm, ids in
                guard vm.group?.groupId == ids.groupId else { return }
                vm.fetchTodoList()
            })
            .disposed(by: bag)
        
        updateGroupCategoryUseCase
            .didUpdateCategoryWithGroupId
            .withUnretained(self)
            .subscribe(onNext: { vm, categoryWithGroupId in
                guard vm.group?.groupId == categoryWithGroupId.groupId else { return }
                vm.fetchTodoList()
            })
            .disposed(by: bag)

    }
    
    func fetchTodoList() {
        switch type {
        case .none:
            return
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
        
        guard let groupId = group?.groupId,
              let currentDate else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[[SocialTodoDaily]]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMemberDailyCalendarUseCase
                    .execute(token: token, groupId: groupId, memberId: memberId, date: currentDate)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
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
        
        guard let groupId = group?.groupId,
              let currentDate else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[[SocialTodoDaily]]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchGroupDailyTodoListUseCase
                    .execute(token: token, groupId: groupId, date: currentDate)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
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

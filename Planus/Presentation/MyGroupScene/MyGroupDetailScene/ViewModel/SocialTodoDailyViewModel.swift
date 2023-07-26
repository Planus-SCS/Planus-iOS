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

    var groupId: Int?
    
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
    // 카테고리 CRUD, 그룹투두 CRUD에 대한 유즈케이스의 이벤트를 받아야함
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchGroupDailyTodoListUseCase: FetchGroupDailyCalendarUseCase,
        fetchMemberDailyCalendarUseCase: FetchGroupMemberDailyCalendarUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchGroupDailyTodoListUseCase = fetchGroupDailyTodoListUseCase
        self.fetchMemberDailyCalendarUseCase = fetchMemberDailyCalendarUseCase
    }
    
    func setGroup(groupId: Int, type: SocialTodoViewModelType, date: Date) {
        self.groupId = groupId
        self.type = type
        self.currentDate = date
        self.currentDateText = dateFormatter.string(from: date)
    }
    
    func transform(input: Input) -> Output {
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
        
        guard let groupId,
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
                errorType: TokenError.noTokenExist
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
        
        guard let groupId,
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
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.scheduledTodoList = list[0]
                self?.unscheduledTodoList = list[1]
                self?.didFetchTodoList.onNext(())
            })
            .disposed(by: bag)
    }

}

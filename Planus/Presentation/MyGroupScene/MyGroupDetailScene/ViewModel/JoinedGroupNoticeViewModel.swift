//
//  JoinedGroupNoticeViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import Foundation
import RxSwift

class JoinedGroupNoticeViewModel {
    var bag = DisposeBag()
    
    var groupId: Int?
    var notice = BehaviorSubject<String?>(value: nil)
    var memberList: [MyMember]?
    var memberListFetched = BehaviorSubject<Void?>(value: nil)
    var memberKickedOutAt = PublishSubject<Int>()
    var needReloadMemberAt = PublishSubject<Int>()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var memberRefreshRequested: Observable<Void>
    }
    
    struct Output {
        var noticeFetched: Observable<String?>
        var didFetchMemberList: Observable<Void?>
        var didRemoveMemberAt: Observable<Int>
        var needReloadMemberAt: Observable<Int>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var fetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase
    var fetchImageUseCase: FetchImageUseCase
    var memberKickOutUseCase: MemberKickOutUseCase
    var setOnlineUseCase: SetOnlineUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase,
        fetchImageUseCase: FetchImageUseCase,
        memberKickOutUseCase: MemberKickOutUseCase,
        setOnlineUseCase: SetOnlineUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchMyGroupMemberListUseCase = fetchMyGroupMemberListUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.memberKickOutUseCase = memberKickOutUseCase
        self.setOnlineUseCase = setOnlineUseCase
    }
    
    func setGroupId(id: Int) {
        self.groupId = id
    }
    
    func transform(input: Input) -> Output {
        bindUseCase()
        
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMemberList()
            })
            .disposed(by: bag)
        
        input
            .memberRefreshRequested
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMemberList()
            })
            .disposed(by: bag)
        
        return Output(
            noticeFetched: notice.asObservable(),
            didFetchMemberList: memberListFetched.asObservable(),
            didRemoveMemberAt: memberKickedOutAt.asObservable(),
            needReloadMemberAt: needReloadMemberAt.asObservable()
        )
    }
    
    func bindUseCase() {
        memberKickOutUseCase
            .didKickOutMemberAt
            .subscribe(onNext: { [weak self] (groupId, memberId) in
                guard let currentGroupId = self?.groupId,
                      groupId == currentGroupId,
                      let index = self?.memberList?.firstIndex(where: { $0.memberId == memberId }) else { return }
                self?.memberList?.remove(at: index)
                self?.memberKickedOutAt.onNext(index)
            })
            .disposed(by: bag)
        
        setOnlineUseCase
            .didChangeOnlineState
            .withUnretained(self)
            .subscribe(onNext: { vm, memberId in
                guard let index = vm.memberList?.firstIndex(where: { $0.memberId == memberId }),
                      var member = vm.memberList?[index] else { return }
                
                member.isOnline = !member.isOnline
                vm.memberList?[index] = member
                vm.needReloadMemberAt.onNext(index)
            })
            .disposed(by: bag)
    }
    
    func fetchMemberList() {
        guard let groupId else { return }
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[MyMember]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchMyGroupMemberListUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.memberList = list
                self?.memberListFetched.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        fetchImageUseCase
            .execute(key: key)
    }
}

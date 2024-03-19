//
//  MyGroupMemberEditViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import Foundation
import RxSwift

class MyGroupMemberEditViewModel {
    
    var bag = DisposeBag()
    
    var groupId: Int?
    var memberList: [MyGroupMemberProfile]?
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didTappedResignButton: Observable<Int>
    }
    
    struct Output {
        var didResignedAt: Observable<Int>
        var didFetchMemberList: Observable<Void?>
        var showMessage: Observable<Message>
    }
    
    var resignRequested = PublishSubject<Void>()
    var resignedAt = PublishSubject<Int>()
    var nowProcessingMemberId: [Int] = []
    var didFetchMemberList = BehaviorSubject<Void?>(value: nil)
    var showMessage = PublishSubject<Message>()
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var fetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase
    var fetchImageUseCase: FetchImageUseCase
    var memberKickOutUseCase: MemberKickOutUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase,
        fetchImageUseCase: FetchImageUseCase,
        memberKickOutUseCase: MemberKickOutUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchMyGroupMemberListUseCase = fetchMyGroupMemberListUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.memberKickOutUseCase = memberKickOutUseCase
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
            .didTappedResignButton
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.resignMember(index: index)
            })
            .disposed(by: bag)
        
        return Output(
            didResignedAt: resignedAt.asObservable(),
            didFetchMemberList: didFetchMemberList.asObservable(),
            showMessage: showMessage.asObservable()
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
                self?.resignedAt.onNext(index)
            })
            .disposed(by: bag)
    }
    
    func resignMember(index: Int) {
        guard let groupId,
              let memberId = memberList?[index].memberId,
              nowProcessingMemberId.filter({ $0 == memberId }).isEmpty else { return }
        nowProcessingMemberId.append(memberId)
        let memberKickOutUseCase = self.memberKickOutUseCase
        
        getTokenUseCase
            .execute()
            .flatMap { token -> Single<Void> in
                return memberKickOutUseCase
                    .execute(token: token, groupId: groupId, memberId: memberId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.nowProcessingMemberId.removeAll(where: { $0 == memberId})
                guard let index = self?.memberList?.firstIndex(where: { $0.memberId == memberId }) else { return }
                self?.memberList?.remove(at: index)
                self?.resignedAt.onNext(index)
            }, onFailure: { [weak self] error in
                self?.nowProcessingMemberId.removeAll(where: { $0 == memberId})
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
        
        memberList?.remove(at: index)
        resignedAt.onNext(index)
    }
    
    func fetchMemberList() {
        guard let groupId else { return }
        let fetchMyGroupMemberListUseCase = self.fetchMyGroupMemberListUseCase
        getTokenUseCase
            .execute()
            .flatMap { token -> Single<[MyGroupMemberProfile]> in
                return fetchMyGroupMemberListUseCase
                    .execute(token: token, groupId: groupId)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.memberList = list
                self?.didFetchMemberList.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        fetchImageUseCase
            .execute(key: key)
    }
}

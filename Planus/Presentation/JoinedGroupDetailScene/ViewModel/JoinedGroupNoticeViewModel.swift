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
    
    struct Input {
        var viewDidLoad: Observable<Void>
    }
    
    struct Output {
        var noticeFetched: Observable<String?>
        var didFetchMemberList: Observable<Void?>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var fetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase
    var fetchImageUseCase: FetchImageUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        fetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase,
        fetchImageUseCase: FetchImageUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.fetchMyGroupMemberListUseCase = fetchMyGroupMemberListUseCase
        self.fetchImageUseCase = fetchImageUseCase
    }
    
    func setGroupId(id: Int) {
        self.groupId = id
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchMemberList()
            })
            .disposed(by: bag)
        
        return Output(
            noticeFetched: notice.asObservable(),
            didFetchMemberList: memberListFetched.asObservable()
        )
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
                errorType: TokenError.noTokenExist
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

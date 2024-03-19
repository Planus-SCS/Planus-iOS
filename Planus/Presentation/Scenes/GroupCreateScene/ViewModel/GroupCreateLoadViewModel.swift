//
//  GroupCreateLoadViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import Foundation
import RxSwift

class GroupCreateLoadViewModel {
    
    var bag = DisposeBag()
    var groupCreate: MyGroupCreationInfo?
    var groupImage: ImageFile?
    
    var groupCreateCompleted = PublishSubject<Int>()
    var groupCreateFailedWithMessage = PublishSubject<String>()
    
    struct Input {
        var viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let didCreateGroup: Observable<Int>
        let didCreateFailed: Observable<String>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var groupCreateUseCase: GroupCreateUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        groupCreateUseCase: GroupCreateUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.groupCreateUseCase = groupCreateUseCase
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.createGroup()
            })
            .disposed(by: bag)
        
        return Output(
            didCreateGroup: groupCreateCompleted.asObservable(),
            didCreateFailed: groupCreateFailedWithMessage.asObservable()
        )
    }
    
    func setGroupCreate(groupCreate: MyGroupCreationInfo, image: ImageFile) {
        self.groupCreate = groupCreate
        self.groupImage = image
    }
    
    func createGroup() {
        guard let groupCreate,
              let groupImage else { return }
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Int> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.groupCreateUseCase
                    .execute(
                        token: token,
                        groupCreate: groupCreate,
                        image: groupImage
                    )
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] groupId in
                self?.groupCreateCompleted.onNext(groupId)
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.groupCreateFailedWithMessage.onNext(message)
            })
            .disposed(by: bag)
    }
}
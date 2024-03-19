//
//  NotificationViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

class NotificationViewModel: ViewModel {
    
    struct UseCases {
        var getTokenUseCase: GetTokenUseCase
        var refreshTokenUseCase: RefreshTokenUseCase
        var setTokenUseCase: SetTokenUseCase
        var fetchJoinApplyListUseCase: FetchJoinApplyListUseCase
        var fetchImageUseCase: FetchImageUseCase
        var acceptGroupJoinUseCase: AcceptGroupJoinUseCase
        var denyGroupJoinUseCase: DenyGroupJoinUseCase
    }
    
    struct Actions {
        var pop: (() -> Void)?
        var finishScene: (() -> Void)?
    }
    
    struct Args {}
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didTapAllowBtnAt: Observable<Int?>
        var didTapDenyBtnAt: Observable<Int?>
        var refreshRequired: Observable<Void>
    }
    
    struct Output {
        var didFetchJoinApplyList: Observable<FetchType?>
        var needRemoveAt: Observable<Int>
        var showMessage: Observable<Message>
    }
    
    var joinAppliedList: [MyGroupJoinAppliance]?
    var nowProcessingJoinId: [Int] = []
    var didFetchJoinApplyList = BehaviorSubject<FetchType?>(value: nil)
    var needRemoveAt = PublishSubject<Int>()
    
    var showMessage = PublishSubject<Message>()
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    vm.fetchJoinApplyList(fetchType: .initail)
                })
            })
            .disposed(by: bag)
        
        input
            .didTapAllowBtnAt
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.acceptGroupJoinAt(index: index)
            })
            .disposed(by: bag)
        
        input
            .didTapDenyBtnAt
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                vm.denyGroupJoinAt(index: index)
            })
            .disposed(by: bag)
        
        input
            .refreshRequired
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    vm.fetchJoinApplyList(fetchType: .refresh)
                })
            })
            .disposed(by: bag)
        
        return Output(
            didFetchJoinApplyList: didFetchJoinApplyList.asObservable(),
            needRemoveAt: needRemoveAt.asObservable(),
            showMessage: showMessage.asObservable()
        )
    }
    
    func acceptGroupJoinAt(index: Int) {
        guard let id = joinAppliedList?[index].groupJoinId,
              nowProcessingJoinId.filter({ $0 == id }).isEmpty else { return }
        nowProcessingJoinId.append(id)
        useCases.getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.acceptGroupJoinUseCase
                    .execute(token: token, applyId: id)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.nowProcessingJoinId.removeAll(where: { $0 == id })
                self?.joinAppliedList?.remove(at: index)
                self?.needRemoveAt.onNext(index)
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
                self?.nowProcessingJoinId.removeAll(where: { $0 == id })
            })
            .disposed(by: bag)
    }
    
    func denyGroupJoinAt(index: Int) {
        guard let id = joinAppliedList?[index].groupJoinId,
              nowProcessingJoinId.filter({ $0 == id }).isEmpty else { return }
        nowProcessingJoinId.append(id)
        useCases.getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.denyGroupJoinUseCase
                    .execute(token: token, applyId: id)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.nowProcessingJoinId.removeAll(where: { $0 == id })
                self?.joinAppliedList?.remove(at: index)
                self?.needRemoveAt.onNext(index)
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
                self?.nowProcessingJoinId.removeAll(where: { $0 == id })
            })
            .disposed(by: bag)
    }
    
    func fetchJoinApplyList(fetchType: FetchType) {
        useCases.getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[MyGroupJoinAppliance]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.fetchJoinApplyListUseCase
                    .execute(token: token)
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.joinAppliedList = list
                self?.didFetchJoinApplyList.onNext((fetchType))
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        useCases
            .fetchImageUseCase
            .execute(key: key)
    }
    
}

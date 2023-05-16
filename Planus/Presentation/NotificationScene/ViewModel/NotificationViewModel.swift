//
//  NotificationViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

class NotificationViewModel {
    var bag = DisposeBag()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didTapAllowBtnAt: Observable<Int?>
        var didTapDenyBtnAt: Observable<Int?>
        var refreshRequired: Observable<Void>
    }
    
    struct Output {
        var didFetchJoinApplyList: Observable<FetchType?>
        var needRemoveAt: Observable<Int>
    }
    
    var joinAppliedList: [GroupJoinApplied]?
    var didFetchJoinApplyList = BehaviorSubject<FetchType?>(value: nil)
    var needRemoveAt = PublishSubject<Int>()
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var setTokenUseCase: SetTokenUseCase
    var fetchJoinApplyListUseCase: FetchJoinApplyListUseCase
    var fetchImageUseCase: FetchImageUseCase
    var acceptGroupJoinUseCase: AcceptGroupJoinUseCase
    var denyGroupJoinUseCase: DenyGroupJoinUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        setTokenUseCase: SetTokenUseCase,
        fetchJoinApplyListUseCase: FetchJoinApplyListUseCase,
        fetchImageUseCase: FetchImageUseCase,
        acceptGroupJoinUseCase: AcceptGroupJoinUseCase,
        denyGroupJoinUseCase: DenyGroupJoinUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.setTokenUseCase = setTokenUseCase
        self.fetchJoinApplyListUseCase = fetchJoinApplyListUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.acceptGroupJoinUseCase = acceptGroupJoinUseCase
        self.denyGroupJoinUseCase = denyGroupJoinUseCase
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchJoinApplyList(fetchType: .initail)
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
                vm.fetchJoinApplyList(fetchType: .refresh)
            })
            .disposed(by: bag)
        
        return Output(
            didFetchJoinApplyList: didFetchJoinApplyList.asObservable(),
            needRemoveAt: needRemoveAt.asObservable()
        )
    }
    
    func acceptGroupJoinAt(index: Int) {
        guard let id = joinAppliedList?[index].groupJoinId else { return }

        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.acceptGroupJoinUseCase
                    .execute(token: token, applyId: id)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] _ in
                /*
                 여기서 저거 알림온거를 삭제한다? 삭제먼저? 아님 요청 응답오면 삭제? 일단 로딩을 띄우도록 하자,,!
                 */
                self?.joinAppliedList?.remove(at: index)
                self?.needRemoveAt.onNext(index)
            })
            .disposed(by: bag)
    }
    
    func denyGroupJoinAt(index: Int) {
        guard let id = joinAppliedList?[index].groupJoinId else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.denyGroupJoinUseCase
                    .execute(token: token, applyId: id)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.joinAppliedList?.remove(at: index)
                self?.needRemoveAt.onNext(index)
            })
            .disposed(by: bag)
    }
    
    func fetchJoinApplyList(fetchType: FetchType) {
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<[GroupJoinApplied]> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.fetchJoinApplyListUseCase
                    .execute(token: token)
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] list in
                self?.joinAppliedList = list
                self?.didFetchJoinApplyList.onNext((fetchType))
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        fetchImageUseCase
            .execute(key: key)
    }
    
}

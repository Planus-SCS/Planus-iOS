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
    }
    
    struct Output {
        var didFetchJoinApplyList: Observable<Void?>
    }
    
    var joinAppliedList: [GroupJoinApplied]?
    var didFetchJoinApplyList = BehaviorSubject<Void?>(value: nil)
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var setTokenUseCase: SetTokenUseCase
    var fetchJoinApplyListUseCase: FetchJoinApplyListUseCase
    var fetchImageUseCase: FetchImageUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        setTokenUseCase: SetTokenUseCase,
        fetchJoinApplyListUseCase: FetchJoinApplyListUseCase,
        fetchImageUseCase: FetchImageUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.setTokenUseCase = setTokenUseCase
        self.fetchJoinApplyListUseCase = fetchJoinApplyListUseCase
        self.fetchImageUseCase = fetchImageUseCase
    }
    
    func transform(input: Input) -> Output {
        input
            .viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.fetchJoinApplyList()
            })
            .disposed(by: bag)
        
        input
            .didTapAllowBtnAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                print(index)
            })
            .disposed(by: bag)
        
        input
            .didTapDenyBtnAt
            .withUnretained(self)
            .subscribe(onNext: { vm, index in
                print(index)
            })
            .disposed(by: bag)
        
        return Output(didFetchJoinApplyList: didFetchJoinApplyList.asObservable())
    }
    
    func fetchJoinApplyList() {
        guard let token = getTokenUseCase.execute() else { return }
        
        fetchJoinApplyListUseCase
            .execute(token: token)
            .subscribe(onSuccess: { [weak self] list in
                self?.joinAppliedList = list
                self?.didFetchJoinApplyList.onNext(())
            })
            .disposed(by: bag)
    }
    
    func fetchImage(key: String) -> Single<Data> {
        fetchImageUseCase
            .execute(key: key)
    }
    
}

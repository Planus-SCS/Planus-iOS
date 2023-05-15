//
//  MyGroupNoticeEditViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import Foundation
import RxSwift

class MyGroupNoticeEditViewModel {
    var bag = DisposeBag()
    
    var groupId: Int?
    var notice = BehaviorSubject<String?>(value: nil)
    var didEditComplete = PublishSubject<Void>()
    var isSaveBtnEnabled = PublishSubject<Bool>()
    
    struct Input {
        var didTapSaveButton: Observable<Void>
        var didChangeNoticeValue: Observable<String?>
    }
    
    struct Output {
        var isSaveBtnEnabled: Observable<Bool>
        var didEditCompleted: Observable<Void>
    }
    
    var getTokenUseCase: GetTokenUseCase
    var refreshTokenUseCase: RefreshTokenUseCase
    var updateNoticeUseCase: UpdateNoticeUseCase
    
    init(
        getTokenUseCase: GetTokenUseCase,
        refreshTokenUseCase: RefreshTokenUseCase,
        updateNoticeUseCase: UpdateNoticeUseCase
    ) {
        self.getTokenUseCase = getTokenUseCase
        self.refreshTokenUseCase = refreshTokenUseCase
        self.updateNoticeUseCase = updateNoticeUseCase
    }
    
    func setNotice(groupId: Int, notice: String) {
        self.groupId = groupId
        self.notice.onNext(notice)
    }
    
    func transform(input: Input) -> Output {
        input
            .didTapSaveButton
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.updateNotice()
            })
            .disposed(by: bag)
        
        input
            .didChangeNoticeValue
            .distinctUntilChanged()
            .bind(to: notice)
            .disposed(by: bag)
        
        return Output(
            isSaveBtnEnabled: isSaveBtnEnabled.asObservable(),
            didEditCompleted: didEditComplete.asObservable()
        )
    }
    
    func updateNotice() {
        guard let groupId,
              let notice = try? notice.value() else { return }
        
        getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.updateNoticeUseCase
                    .execute(token: token, groupNotice: GroupNotice(groupId: groupId, notice: notice))
            }
            .handleRetry(
                retryObservable: refreshTokenUseCase.execute(),
                errorType: TokenError.noTokenExist
            )
            .subscribe(onSuccess: { [weak self] _ in
                self?.didEditComplete.onNext(())
            }, onError: {
                print($0)
            })
            .disposed(by: bag)
    }
}
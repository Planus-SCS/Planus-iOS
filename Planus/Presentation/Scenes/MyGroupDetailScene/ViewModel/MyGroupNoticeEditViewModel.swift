//
//  MyGroupNoticeEditViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import Foundation
import RxSwift

class MyGroupNoticeEditViewModel: ViewModel {
    
    struct UseCases {
        let getTokenUseCase: GetTokenUseCase
        let refreshTokenUseCase: RefreshTokenUseCase
        let updateNoticeUseCase: UpdateNoticeUseCase
    }
    
    struct Actions {
        let pop: (() -> Void)?
    }
    
    struct Args {
        let groupId: Int
        let notice: String
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    var groupId: Int
    var notice: BehaviorSubject<String?>
    
    var isSaveBtnEnabled = BehaviorSubject<Bool?>(value: nil)
    var showMessage = PublishSubject<Message>()
    
    struct Input {
        var didTapSaveButton: Observable<Void>
        var didChangeNoticeValue: Observable<String?>
        var backBtnTapped: Observable<Void>
    }
    
    struct Output {
        var isSaveBtnEnabled: Observable<Bool?>
        var showMessage: Observable<Message>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
        
        self.groupId = injectable.args.groupId
        self.notice = BehaviorSubject<String?>(value: injectable.args.notice)
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
        
        input
            .backBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.actions.pop?()
            })
            .disposed(by: bag)
        
        notice
            .withUnretained(self)
            .subscribe(onNext: { vm, text in
                guard let text else {
                    vm.isSaveBtnEnabled.onNext(false)
                    return
                }
                vm.isSaveBtnEnabled.onNext(!text.isEmpty)
            })
            .disposed(by: bag)
        
        return Output(
            isSaveBtnEnabled: isSaveBtnEnabled.asObservable(),
            showMessage: showMessage.asObservable()
        )
    }
    
    func updateNotice() {
        guard let notice = try? notice.value() else { return }
        
        useCases
            .getTokenUseCase
            .execute()
            .flatMap { [weak self] token -> Single<Void> in
                guard let self else {
                    throw DefaultError.noCapturedSelf
                }
                return self.useCases.updateNoticeUseCase
                    .execute(token: token, groupNotice: GroupNotice(groupId: self.groupId, notice: notice))
            }
            .handleRetry(
                retryObservable: useCases.refreshTokenUseCase.execute(),
                errorType: NetworkManagerError.tokenExpired
            )
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.actions.pop?()
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
}

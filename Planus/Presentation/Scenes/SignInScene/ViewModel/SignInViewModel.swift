//
//  SignInViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import Foundation
import RxSwift
import AuthenticationServices

final class SignInViewModel: ViewModel {
    
    struct UseCases {
        let kakaoSignInUseCase: KakaoSignInUseCase
        let googleSignInUseCase: GoogleSignInUseCase
        let appleSignInUseCase: AppleSignInUseCase
        let convertToSha256UseCase: ConvertToSha256UseCase
        let setSignedInSNSTypeUseCase: SetSignedInSNSTypeUseCase
        let revokeAppleTokenUseCase: RevokeAppleTokenUseCase
        let setTokenUseCase: SetTokenUseCase
    }
    
    struct Actions {
        let showWebViewSignInPage: ((_ type: SocialRedirectionType, _ completion: @escaping (String) -> Void) -> Void)?
        let showMainTabFlow: (() -> Void)?
    }
    
    struct Args {}
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    var showAppleSignInPageWith = PublishSubject<ASAuthorizationAppleIDRequest>()
    var showMessage = PublishSubject<Message>()
        
    struct Input {
        var kakaoSignInTapped: Observable<Void>
        var googleSignInTapped: Observable<Void>
        var appleSignInTapped: Observable<Void>
        var didReceiveAppleIdentityToken: Observable<(String, PersonNameComponents?)>
    }
    
    struct Output {
        var showAppleSignInPage: Observable<ASAuthorizationAppleIDRequest>
        var showMessage: Observable<Message>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        self.actions = injectable.actions
    }
    
    func transform(input: Input) -> Output {        
        input
            .kakaoSignInTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.signInKakao()
            })
            .disposed(by: bag)
        
        input
            .googleSignInTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                vm.signInGoogle()
            })
            .disposed(by: bag)
        
        input
            .appleSignInTapped
            .withUnretained(self)
            .subscribe(onNext: { vm, _ in
                let request = vm.generateAppleSignInRequest()
                vm.showAppleSignInPageWith.onNext(request)
            })
            .disposed(by: bag)
        
        input
            .didReceiveAppleIdentityToken
            .withUnretained(self)
            .subscribe(onNext: { vm, personalInfo in
                vm.signInApple(identityToken: personalInfo.0, fullName: personalInfo.1)
            })
            .disposed(by: bag)
        
        return Output(
            showAppleSignInPage: showAppleSignInPageWith.asObservable(),
            showMessage: showMessage.asObservable()
        )
    }
    
    func generateAppleSignInRequest() -> ASAuthorizationAppleIDRequest {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = useCases.convertToSha256UseCase.execute(AppleSignInNonce.nonce)
        return request
    }
    
    func signInKakao() {
        actions.showWebViewSignInPage?(.kakao) { [weak self] code in
            guard let self else { return }
            self.useCases.kakaoSignInUseCase.execute(code: code)
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onSuccess: { [weak self] token in
                    self?.useCases.setTokenUseCase.execute(token: token)
                    self?.useCases.setSignedInSNSTypeUseCase.execute(type: .kakao)
                    self?.actions.showMainTabFlow?()
                }, onFailure: { [weak self] error in
                    guard let error = error as? NetworkManagerError,
                          case NetworkManagerError.clientError(let status, let message) = error,
                          let message = message else { return }
                    self?.showMessage.onNext(Message(text: message, state: .warning))
                })
                .disposed(by: self.bag)
        }
    }
    
    func signInGoogle() {
        actions.showWebViewSignInPage?(.google) { [weak self] code in
            guard let self else { return }
            self.useCases.googleSignInUseCase.execute(code: code)
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onSuccess: { [weak self] token in
                    self?.useCases.setTokenUseCase.execute(token: token)
                    self?.useCases.setSignedInSNSTypeUseCase.execute(type: .google)
                    self?.actions.showMainTabFlow?()
                }, onFailure: { [weak self] error in
                    guard let error = error as? NetworkManagerError,
                          case NetworkManagerError.clientError(let status, let message) = error,
                          let message = message else { return }
                    self?.showMessage.onNext(Message(text: message, state: .warning))
                })
                .disposed(by: self.bag)
        }
    }
    
    func signInApple(identityToken: String, fullName: PersonNameComponents?) {
        self.useCases.appleSignInUseCase.execute(identityToken: identityToken, fullName: fullName)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] token in
                self?.useCases.setTokenUseCase.execute(token: token)
                self?.useCases.setSignedInSNSTypeUseCase.execute(type: .apple)
                self?.actions.showMainTabFlow?()
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
}

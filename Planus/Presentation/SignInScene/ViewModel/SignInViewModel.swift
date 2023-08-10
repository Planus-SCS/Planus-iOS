//
//  SignInViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import Foundation
import RxSwift
import AuthenticationServices

struct SignInViewModelActions {
    var showWebViewSignInPage: ((_ type: SocialRedirectionType, _ completion: @escaping (String) -> Void) -> Void)?
    var showMainTabFlow: (() -> Void)?
}

class SignInViewModel {
    var bag = DisposeBag()
    
    var actions: SignInViewModelActions?
    
    var showAppleSignInPageWith = PublishSubject<ASAuthorizationAppleIDRequest>()
    var showMessage = PublishSubject<Message>()

    let kakaoSignInUseCase: KakaoSignInUseCase
    let googleSignInUseCase: GoogleSignInUseCase
    let appleSignInUseCase: AppleSignInUseCase
    let convertToSha256UseCase: ConvertToSha256UseCase
    
    let setTokenUseCase: SetTokenUseCase
        
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
        kakaoSignInUseCase: KakaoSignInUseCase,
        googleSignInUseCase: GoogleSignInUseCase,
        appleSignInUseCase: AppleSignInUseCase,
        convertToSha256UseCase: ConvertToSha256UseCase,
        setTokenUseCase: SetTokenUseCase
    ) {
        self.kakaoSignInUseCase = kakaoSignInUseCase
        self.googleSignInUseCase = googleSignInUseCase
        self.appleSignInUseCase = appleSignInUseCase
        self.convertToSha256UseCase = convertToSha256UseCase
        self.setTokenUseCase = setTokenUseCase
    }
    
    func setActions(actions: SignInViewModelActions) {
        self.actions = actions
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
        request.nonce = convertToSha256UseCase.execute(AppleSignInNonce.nonce)
        return request
    }
    
    func signInKakao() {
        actions?.showWebViewSignInPage?(.kakao) { [weak self] code in
            guard let self else { return }
            self.kakaoSignInUseCase.execute(code: code)
                .subscribe(onSuccess: { [weak self] token in
                    self?.setTokenUseCase.execute(token: token)
                    self?.actions?.showMainTabFlow?()
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
        actions?.showWebViewSignInPage?(.google) { [weak self] code in
            guard let self else { return }
            self.googleSignInUseCase.execute(code: code)
                .subscribe(onSuccess: { [weak self] token in
                    self?.setTokenUseCase.execute(token: token)
                    self?.actions?.showMainTabFlow?()
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
        self.appleSignInUseCase.execute(identityToken: identityToken, fullName: fullName)
            .subscribe(onSuccess: { [weak self] token in
                self?.setTokenUseCase.execute(token: token)
                self?.actions?.showMainTabFlow?()
            }, onFailure: { [weak self] error in
                guard let error = error as? NetworkManagerError,
                      case NetworkManagerError.clientError(let status, let message) = error,
                      let message = message else { return }
                self?.showMessage.onNext(Message(text: message, state: .warning))
            })
            .disposed(by: bag)
    }
}

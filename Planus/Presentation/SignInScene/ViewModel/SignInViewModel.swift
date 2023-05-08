//
//  SignInViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import Foundation
import RxSwift

struct SignInViewModelActions {
    var showWebViewSignInPage: ((_ type: SocialRedirectionType, _ completion: @escaping (String) -> Void) -> Void)?
    var showMainTabFlow: (() -> Void)?
}

class SignInViewModel {
    var bag = DisposeBag()
    
    var actions: SignInViewModelActions?

    let kakaoSignInUseCase: KakaoSignInUseCase
    let googleSignInUseCase: GoogleSignInUseCase
    
    let setTokenUseCase: SetTokenUseCase
        
    struct Input {
        var kakaoSignInTapped: Observable<Void>
        var googleSignInTapped: Observable<Void>
        var appleSignInTapped: Observable<Void>
        var didReceiveAppleIdentityToken: Observable<String>
    }
    
    struct Output {
        var showAppleSignInPage: Observable<Void>
    }
    
    init(
        kakaoSignInUseCase: KakaoSignInUseCase,
        googleSignInUseCase: GoogleSignInUseCase,
        setTokenUseCase: SetTokenUseCase
    ) {
        self.kakaoSignInUseCase = kakaoSignInUseCase
        self.googleSignInUseCase = googleSignInUseCase
        self.setTokenUseCase = setTokenUseCase
    }
    
    func setActions(actions: SignInViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        let showAppleSignInPage = PublishSubject<Void>()
        
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
            .subscribe(onNext: {
                showAppleSignInPage.onNext(())
            })
            .disposed(by: bag)
        
        input
            .didReceiveAppleIdentityToken
            .withUnretained(self)
            .subscribe(onNext: { vm, token in
                vm.signInApple(token: token)
            })
            .disposed(by: bag)
        
        return Output(
            showAppleSignInPage: showAppleSignInPage.asObservable()
        )
    }
    
    
    func signInKakao() {
        actions?.showWebViewSignInPage?(.kakao) { [weak self] code in
            guard let self else { return }
            self.kakaoSignInUseCase.execute(code: code)
                .subscribe(onSuccess: { token in
                    self.setTokenUseCase.execute(token: token)
                    self.actions?.showMainTabFlow?()
                }, onFailure: { error in
                    print(error)
                })
                .disposed(by: self.bag)
        }
    }
    
    func signInGoogle() {
        actions?.showWebViewSignInPage?(.google) { [weak self] code in
            guard let self else { return }
            self.googleSignInUseCase.execute(code: code)
                .subscribe(onSuccess: { token in
                    self.setTokenUseCase.execute(token: token)
                    print(token)
                    self.actions?.showMainTabFlow?()
                }, onFailure: { error in
                    
                })
                .disposed(by: self.bag)
        }
    }
    
    func signInApple(token: String) {
        
    }
}

//
//  SignInViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import Foundation
import RxSwift

class SignInViewModel {
    var bag = DisposeBag()
    
    struct Input {
        var kakaoSignInTapped: Observable<Void>
        var googleSignInTapped: Observable<Void>
        var appleSignInTapped: Observable<Void>
    }
    
    struct Output {
        var showKakaoSignInPage: Observable<Void>
        var showGoogleSignInPage: Observable<Void>
        var showAppleSignInPage: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let showKakaoSignInPage = PublishSubject<Void>()
        let showGoogleSignInPage = PublishSubject<Void>()
        let showAppleSignInPage = PublishSubject<Void>()
        
        input
            .kakaoSignInTapped
            .subscribe(onNext: {
                showKakaoSignInPage.onNext(())
            })
            .disposed(by: bag)
        
        input
            .googleSignInTapped
            .subscribe(onNext: {
                showGoogleSignInPage.onNext(())
            })
            .disposed(by: bag)
        
        input
            .appleSignInTapped
            .subscribe(onNext: {
                showAppleSignInPage.onNext(())
            })
            .disposed(by: bag)
        
        return Output(
            showKakaoSignInPage: showKakaoSignInPage.asObservable(),
            showGoogleSignInPage: showGoogleSignInPage.asObservable(),
            showAppleSignInPage: showAppleSignInPage.asObservable()
        )
    }
    
    func signInKakao() {

    }
}

//
//  RedirectionalWebViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation
import RxSwift

struct RedirectionalWebViewActions {
    var dismissWithOutAuth: (() -> Void)?
}

class RedirectionalWebViewModel {
    
    var bag = DisposeBag()
    
    var actions: RedirectionalWebViewActions?
    
    var type: SocialRedirectionType
    var completion: (String) -> Void
    
    var needToDismiss = PublishSubject<Void>()
    
    struct Input {
        var didFetchedCode: Observable<String>
    }
    
    struct Output {
        var needDismiss: Observable<Void>
    }
    
    init(type: SocialRedirectionType, completion: @escaping (String) -> Void) {
        self.type = type
        self.completion = completion
    }
    
    func setActions(actions: RedirectionalWebViewActions) {
        self.actions = actions
    }
        
    func transform(input: Input) -> Output {
        
        input.didFetchedCode
            .withUnretained(self)
            .subscribe(onNext: { vm, code in
                vm.codeFetched(code: code)
            })
            .disposed(by: bag)
        
        return Output(needDismiss: needToDismiss)
    }

    func codeFetched(code: String) {
        needToDismiss.onNext(())
        completion(code)
    }
    
}

enum SocialRedirectionType {
    case kakao
    case google
    
    var requestURL: String {
        switch self {
        case .kakao:
            return KakaoAuthURL.kakaoAuthCodeURL
        case .google:
            return ""
        }
    }
    
    var redirectionURI: String {
        switch self {
        case .kakao:
            return KakaoAuthURL.kakaoAuthCodeRedirectURI
        case .google:
            return ""
        }
    }
}

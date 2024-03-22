//
//  RedirectionalWebViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation
import RxSwift

class RedirectionalWebViewModel: ViewModel {
    
    struct UseCases {}
    
    struct Actions {
        let dismissWithOutAuth: (() -> Void)?
    }
    
    struct Args {
        let type: SocialRedirectionType
        let completion: (String) -> Void
    }
    
    struct Injectable {
        let actions: Actions
        let args: Args
    }
    
    
    var bag = DisposeBag()
    
    let useCases: UseCases
    let actions: Actions
    
    var type: SocialRedirectionType
    var completion: ((String) -> Void)?
    
    var needToDismiss = PublishSubject<Void>()
    
    struct Input {
        var didFetchedCode: Observable<String>
    }
    
    struct Output {
        var needDismiss: Observable<Void>
    }
    
    init(
        useCases: UseCases,
        injectable: Injectable
    ) {
        self.useCases = useCases
        
        self.type = injectable.args.type
        self.completion = injectable.args.completion
        
        self.actions = injectable.actions
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
        completion?(code)
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
            return GoogleAuthURL.googleAuthCodeURL
        }
    }
    
    var redirectionURI: String {
        switch self {
        case .kakao:
            return KakaoAuthURL.redirectURI
        case .google:
            return GoogleAuthURL.redirectURI
        }
    }
    
    var URLSchemes: [String] {
        switch self {
        case .kakao:
            return ["kakaokompassauth", "kakaolink", "kakaoplus", "kakaotalk"]
        case .google:
            return []
        }
    }
    
    var storeAppId: String? {
        switch self {
        case .kakao:
            return "id362057947"
        case .google:
            return nil
        }
    }
}

//
//  SignInAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class SignInPresentationAssembly: Assembly {
    func assemble(container: Container) {
        assembleSignIn(container: container)
        assembleRedirectionalWeb(container: container)
    }
    
    func assembleSignIn(container: Container) {
        container.register(SignInViewModel.self) { (r, injectable: SignInViewModel.Injectable) in
            return SignInViewModel(
                useCases: SignInViewModel.UseCases(
                    kakaoSignInUseCase: r.resolve(KakaoSignInUseCase.self)!,
                    googleSignInUseCase: r.resolve(GoogleSignInUseCase.self)!,
                    appleSignInUseCase: r.resolve(AppleSignInUseCase.self)!,
                    convertToSha256UseCase: r.resolve(ConvertToSha256UseCase.self)!,
                    setSignedInSNSTypeUseCase: r.resolve(SetSignedInSNSTypeUseCase.self)!,
                    revokeAppleTokenUseCase: r.resolve(RevokeAppleTokenUseCase.self)!,
                    setTokenUseCase: r.resolve(SetTokenUseCase.self)!
                ),
                injectable: injectable
            )
        }
    }
    
    func assembleRedirectionalWeb(container: Container) {
        container.register(RedirectionalWebViewModel.self) { (r, injectable: RedirectionalWebViewModel.Injectable) in
            return RedirectionalWebViewModel(useCases: .init(), injectable: injectable)
        }
    }
}

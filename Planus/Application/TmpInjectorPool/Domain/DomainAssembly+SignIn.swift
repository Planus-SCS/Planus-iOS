//
//  DomainAssembly+SignIn.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {
    
    func assembleSignIn(container: Container) {
        container.register(KakaoSignInUseCase.self) { r in
            let socialAuthRepository = r.resolve(SocialAuthRepository.self)!
            return DefaultKakaoSignInUseCase(socialAuthRepository: socialAuthRepository)
        }
        
        container.register(GoogleSignInUseCase.self) { r in
            let socialAuthRepository = r.resolve(SocialAuthRepository.self)!
            return DefaultGoogleSignInUseCase(socialAuthRepository: socialAuthRepository)
        }
        
        container.register(AppleSignInUseCase.self) { r in
            let socialAuthRepository = r.resolve(SocialAuthRepository.self)!
            return DefaultAppleSignInUseCase(socialAuthRepository: socialAuthRepository)
        }
        
        container.register(SetSignedInSNSTypeUseCase.self) { r in
            let socialAuthRepository = r.resolve(SocialAuthRepository.self)!
            return DefaultSetSignedInSNSTypeUseCase(socialAuthRepository: socialAuthRepository)
        }
        
        container.register(GetSignedInSNSTypeUseCase.self) { r in
            let socialAuthRepository = r.resolve(SocialAuthRepository.self)!
            return DefaultGetSignedInSNSTypeUseCase(socialAuthRepository: socialAuthRepository)
        }
        
        container.register(RevokeAppleTokenUseCase.self) { r in
            let socialAuthRepository = r.resolve(SocialAuthRepository.self)!
            return DefaultRevokeAppleTokenUseCase(socialAuthRepository: socialAuthRepository)
        }
    }
    
}

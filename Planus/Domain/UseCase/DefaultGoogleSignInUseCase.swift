//
//  DefaultGoogleSignInUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

class DefaultGoogleSignInUseCase: GoogleSignInUseCase {
    
    let socialAuthRepository: SocialAuthRepository
    let tokenRepository: TokenRepository
    
    init(
        socialAuthRepository: SocialAuthRepository,
        tokenRepository: TokenRepository
    ) {
        self.socialAuthRepository = socialAuthRepository
    }
    
    func execute(code: String) -> Single<Data> {
        return socialAuthRepository.kakaoSignIn(code: code)
    }
}

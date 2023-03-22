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
    
    init(socialAuthRepository: SocialAuthRepository) {
        self.socialAuthRepository = socialAuthRepository
    }
    
    func execute(code: String) -> Single<Data> {
        return socialAuthRepository.kakaoSignIn(code: code)
    }
}

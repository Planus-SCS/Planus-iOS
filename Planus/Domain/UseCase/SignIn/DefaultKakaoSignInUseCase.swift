//
//  DefaultKakaoSignInUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

final class DefaultKakaoSignInUseCase: KakaoSignInUseCase {
    
    let socialAuthRepository: SocialAuthRepository
    
    init(
        socialAuthRepository: SocialAuthRepository
    ) {
        self.socialAuthRepository = socialAuthRepository
    }
    
    func execute(code: String) -> Single<Token> {
        return socialAuthRepository
            .kakaoSignIn(code: code)
            .map {
                return $0.data.toDomain()
            }
    }
}

//
//  DefaultAppleSignInUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/07.
//

import Foundation
import RxSwift

final class DefaultAppleSignInUseCase: AppleSignInUseCase {
    let socialAuthRepository: SocialAuthRepository
    
    init(
        socialAuthRepository: SocialAuthRepository
    ) {
        self.socialAuthRepository = socialAuthRepository
    }
    
    func execute(identityToken: String, fullName: PersonNameComponents?) -> Single<Token> {
        return socialAuthRepository
            .appleSignIn(requestDTO: AppleSignInRequestDTO(
                identityToken: identityToken,
                fullName: fullName
            ))
            .map {
                return $0.data.toDomain()
            }
    }
}

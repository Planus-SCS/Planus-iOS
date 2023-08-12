//
//  DefaultGetAppleTokenUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/12.
//

import Foundation
import RxSwift

class DefaultGetAppleTokenUseCase: GetAppleTokenUseCase {
    let socialAuthRepository: SocialAuthRepository
    
    init(
        socialAuthRepository: SocialAuthRepository
    ) {
        self.socialAuthRepository = socialAuthRepository
    }
    
    func execute(authorizationCode: String) -> Single<Token> {
        return socialAuthRepository
            .getAppleToken(authorizationCode: authorizationCode)
            .map { $0.data.toDomain() }
    }
}

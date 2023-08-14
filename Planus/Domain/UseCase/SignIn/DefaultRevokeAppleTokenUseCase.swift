//
//  DefaultResignAppleUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/14.
//

import Foundation
import RxSwift

class DefaultRevokeAppleTokenUseCase: RevokeAppleTokenUseCase {
    let clientId: String = "com.SCSY.Planus"
    let socialAuthRepository: SocialAuthRepository
    
    init(socialAuthRepository: SocialAuthRepository) {
        self.socialAuthRepository = socialAuthRepository
    }
    
    func execute(authorizationCode: String) -> Single<Void> {
        socialAuthRepository
            .fetchAppleClientSecret()
            .map { $0.data }
            .flatMap { [weak self] secret -> Single<(AppleClientSecret, Token)> in
                guard let self else { throw DefaultError.noCapturedSelf }
                return self.socialAuthRepository
                    .fetchAppleToken(clientID: self.clientId, clientSecret: secret.clientSecret, authorizationCode: authorizationCode)
                    .map { (secret, Token(accessToken: $0.access_token, refreshToken: $0.refresh_token)) }
            }
            .flatMap { [weak self] args -> Single<Void> in
                let (clientSecret, token) = args
                guard let self else { throw DefaultError.noCapturedSelf }
                return self.socialAuthRepository
                    .revokeAppleToken(clientID: self.clientId, clientSecret: clientSecret.clientSecret, refreshToken: token.refreshToken)
            }
    }
}

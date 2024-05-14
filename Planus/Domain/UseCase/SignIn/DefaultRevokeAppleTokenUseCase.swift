//
//  DefaultResignAppleUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/14.
//

import Foundation
import RxSwift

final class DefaultRevokeAppleTokenUseCase: RevokeAppleTokenUseCase {
    private let clientId: String = "com.SCSY.Planus"
    private let socialAuthRepository: SocialAuthRepository
    
    init(socialAuthRepository: SocialAuthRepository) {
        self.socialAuthRepository = socialAuthRepository
    }
    
    func execute(token: Token, authorizationCode: String) -> Single<Void> {
        socialAuthRepository
            .fetchAppleClientSecret(token: token.accessToken)
            .map { $0.data }
            .flatMap { secret -> Single<(AppleClientSecret, Token)> in
                return self.socialAuthRepository
                    .fetchAppleToken(clientID: self.clientId, clientSecret: secret.clientSecret, authorizationCode: authorizationCode)
                    .map { (secret, Token(accessToken: $0.access_token, refreshToken: $0.refresh_token)) }
            }
            .flatMap { args -> Single<Void> in
                let (clientSecret, token) = args
                return self.socialAuthRepository
                    .revokeAppleToken(clientID: self.clientId, clientSecret: clientSecret.clientSecret, refreshToken: token.refreshToken)
            }
    }
}

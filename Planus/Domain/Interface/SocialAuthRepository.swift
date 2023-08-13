//
//  SocialAuthRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

protocol SocialAuthRepository {
    func kakaoSignIn(code: String) -> Single<ResponseDTO<TokenResponseDataDTO>>
    func googleSignIn(code: String) -> Single<ResponseDTO<TokenResponseDataDTO>>
    func appleSignIn(requestDTO: AppleSignInRequestDTO) -> Single<ResponseDTO<TokenResponseDataDTO>>
    func getSignedInSNSType() -> SocialAuthType?
    func setSignedInSNSType(type: SocialAuthType)
    func fetchAppleClientSecret() -> Single<ResponseDTO<AppleClientSecret>>
    func fetchAppleToken(clientID: String, clientSecret: String, authorizationCode: String) -> Single<AppleIDTokenResponseDTO>
    func revokeAppleToken(clientID: String, clientSecret: String, refreshToken: String) -> Single<Void>
}

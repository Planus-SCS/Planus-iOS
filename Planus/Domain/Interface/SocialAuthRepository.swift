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
    func getAppleToken(authorizationCode: String) -> Single<ResponseDTO<TokenRefreshResponseDataDTO>>
    func getSignedInSNSType() -> SocialAuthType?
    func setSignedInSNSType(type: SocialAuthType)
}

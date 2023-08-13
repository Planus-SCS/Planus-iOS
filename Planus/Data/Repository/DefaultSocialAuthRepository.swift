//
//  SocialAuthRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

class DefaultSocialAuthRepository: SocialAuthRepository {
    
    let apiProvider: APIProvider
    let keyValueStorage: KeyValueStorage
    
    init(
        apiProvider: APIProvider,
        keyValueStorage: KeyValueStorage
    ) {
        self.apiProvider = apiProvider
        self.keyValueStorage = keyValueStorage
    }
    
    func kakaoSignIn(code: String) -> Single<ResponseDTO<TokenResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.oauthKakao,
            requestType: .get,
            body: nil,
            query: ["code": code],
            header: ["Content-Type": "application/json"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TokenResponseDataDTO>.self
        )
    }
    
    func googleSignIn(code: String) -> Single<ResponseDTO<TokenResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.oauthGoogle,
            requestType: .get,
            body: nil,
            query: ["code": code],
            header: nil
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TokenResponseDataDTO>.self
        )
    }
    
    func appleSignIn(requestDTO: AppleSignInRequestDTO) -> Single<ResponseDTO<TokenResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.oauthAppleSignIn,
            requestType: .post,
            body: requestDTO,
            query: nil,
            header: ["Content-Type": "application/json"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TokenResponseDataDTO>.self
        )
    }
    
    func getAppleToken(authorizationCode: String) -> Single<ResponseDTO<TokenRefreshResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.oauthAppleToken,
            requestType: .get,
            body: nil,
            query: ["code": authorizationCode],
            header: nil
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TokenRefreshResponseDataDTO>.self
        )
    }
    
    func getSignedInSNSType() -> SocialAuthType? {
        let typeString = keyValueStorage.get(key: SocialAuthType.authType) as? String
        return SocialAuthType(rawValue: typeString ?? String())
    }
    
    func setSignedInSNSType(type: SocialAuthType) {
        keyValueStorage.set(key: SocialAuthType.authType, value: type.rawValue)
    }
}

struct AppleSignInRequestDTO: Codable {
    var identityToken: String
    var fullName: PersonNameComponents?
}

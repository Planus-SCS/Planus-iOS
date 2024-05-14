//
//  SocialAuthRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

final class DefaultSocialAuthRepository: SocialAuthRepository {

    private let apiProvider: APIProvider
    private let keyValueStorage: PersistantKeyValueStorage
    
    init(
        apiProvider: APIProvider,
        keyValueStorage: PersistantKeyValueStorage
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
        
        return apiProvider.request(
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
        
        return apiProvider.request(
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
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<TokenResponseDataDTO>.self
        )
    }
    
    func fetchAppleClientSecret(token: String) -> Single<ResponseDTO<AppleClientSecret>> {
        let endPoint = APIEndPoint(
            url: URLPool.oauthAppleSecret,
            requestType: .get,
            body: nil,
            query: nil,
            header:  ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.request(endPoint: endPoint, type: ResponseDTO<AppleClientSecret>.self)
    }
    
    func fetchAppleToken(clientID: String, clientSecret: String, authorizationCode: String) -> Single<AppleIDTokenResponseDTO> {
        let endPoint = APIEndPoint(
            url: URLPool.oauthAppleToken,
            requestType: .post,
            body: nil,
            query: ["client_id": clientID, "client_secret": clientSecret, "code": authorizationCode, "grant_type": "authorization_code"],
            header: ["Content-Type": "application/x-www-form-urlencoded"]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: AppleIDTokenResponseDTO.self
        )
    }
    
    func revokeAppleToken(clientID: String, clientSecret: String, refreshToken: String) -> Single<Void> {
        let endPoint = APIEndPoint(
            url: URLPool.oauthAppleRevoke,
            requestType: .post,
            body: nil,
            query: ["client_id": clientID, "client_secret": clientSecret, "token": refreshToken, "token_type_hint": "refresh_token"],
            header: ["Content-Type": "application/x-www-form-urlencoded"]
        )
        
        return apiProvider.request(endPoint: endPoint).map { _ in () }
    }
        

    func getSignedInSNSType() -> SocialAuthType? {
        let typeString = keyValueStorage.get(key: SocialAuthType.authType) as? String
        return SocialAuthType(rawValue: typeString ?? String())
    }
    
    func setSignedInSNSType(type: SocialAuthType) {
        keyValueStorage.set(key: SocialAuthType.authType, value: type.rawValue)
    }
}

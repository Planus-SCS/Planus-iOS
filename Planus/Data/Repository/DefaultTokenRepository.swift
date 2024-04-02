//
//  DefaultTokenRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

final class DefaultTokenRepository: TokenRepository {
    
    let apiProvider: APIProvider
    let keyValueStorage: KeyValueStorage
    
    init(
        apiProvider: APIProvider,
        keyValueStorage: KeyValueStorage
    ) {
        self.keyValueStorage = keyValueStorage
        self.apiProvider = apiProvider
    }
    
    func refresh() -> Single<ResponseDTO<TokenRefreshResponseDataDTO>> {
        guard let token = get() else {
            return Single.error(TokenError.noTokenExist)
        }
                
        let endPoint = APIEndPoint(
            url: URLPool.refreshToken,
            requestType: .post,
            body: token.toDTO(),
            query: nil,
            header: ["Content-Type": "application/json"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TokenRefreshResponseDataDTO>.self
        )
    }
    
    func get() -> Token? {
        guard let accessToken = keyValueStorage.get(key: "accessToken"),
              let refreshToken = keyValueStorage.get(key: "refreshToken") else {
            return nil
        }
        let token = Token(
            accessToken: String(decoding: accessToken as! Data, as: UTF8.self),
            refreshToken: String(decoding: refreshToken as! Data, as: UTF8.self)
        )
        return token
    }
    
    func set(token: Token) {
        keyValueStorage.set(
            key: "accessToken",
            value: token.accessToken.data(using: .utf8, allowLossyConversion: false) as Any
        )
        keyValueStorage.set(
            key: "refreshToken",
            value: token.refreshToken.data(using: .utf8, allowLossyConversion: false) as Any
        )
    }
    
    func delete() {
        keyValueStorage.remove(key: "accessToken")
        keyValueStorage.remove(key: "refreshToken")
    }
}

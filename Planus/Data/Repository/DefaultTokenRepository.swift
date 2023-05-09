//
//  DefaultTokenRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

class DefaultTokenRepository: TokenRepository {
    
    let apiProvider: APIProvider
    let keyChainManager: KeyChainManager
    
    init(
        apiProvider: APIProvider,
        keyChainManager: KeyChainManager
    ) {
        self.keyChainManager = keyChainManager
        self.apiProvider = apiProvider
    }
    
    func refresh() -> Single<ResponseDTO<TokenRefreshResponseDataDTO>>? {
        guard let token = get() else { return nil }
                
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
    
    func get() -> Token? { //네트워킹 할때마다 사용됨
        guard let accessToken = keyChainManager.get(key: "accessToken"),
              let refreshToken = keyChainManager.get(key: "refreshToken") else {
            return nil
        }
        let token = Token(
            accessToken: String(decoding: accessToken as! Data, as: UTF8.self),
            refreshToken: String(decoding: refreshToken as! Data, as: UTF8.self)
        )
        return token
    }
    
    func set(token: Token) { //최초, refreshToken 만료 시에만 사용됨
        keyChainManager.set(
            key: "accessToken",
            value: token.accessToken.data(using: .utf8, allowLossyConversion: false) as Any
        )
        keyChainManager.set(
            key: "refreshToken",
            value: token.refreshToken.data(using: .utf8, allowLossyConversion: false) as Any
        )
    }
    
    func delete() {
        keyChainManager.delete(key: "accessToken")
        keyChainManager.delete(key: "refreshToken")
    }
}

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
    
    init(keyChainManager: KeyChainManager) {
        self.keyChainManager = keyChainManager
    }
    
    func refresh() -> Single<Void>? {
        guard let refreshToken = keyChainManager.get(key: "refreshToken") as? String else {
            return nil
        }
        
        let endPoint = APIEndPoint(
            url: "localhost:8080/app/auth/token-reissue",
            requestType: .post,
            body: nil,
            query: nil,
            header: ["Authorization": refreshToken]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: Token.self
        )
        .map { [weak self] in
            self?.set(token: $0)
            return ()
        }
    }
    
    func get() -> Token? { //네트워킹 할때마다 사용됨
        guard let accessToken = keyChainManager.get(key: "accessToken") as? String,
              let refreshToken = keyChainManager.get(key: "refreshToken") as? String else {
            return nil
        }
        return Token(accessToken: accessToken, refreshToken: refreshToken)
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

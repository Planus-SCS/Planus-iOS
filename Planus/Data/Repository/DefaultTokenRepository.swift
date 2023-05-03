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
    
    func refresh() -> Single<Void>? {
        guard let token = get() else { return nil }
                
        let endPoint = APIEndPoint(
            url: "localhost:8080/app/auth/token-reissue",
            requestType: .post,
            body: token.toDTO(),
            query: nil,
            header: nil
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TokenResponseDataDTO>.self
        )
        .map { [weak self] dto in
            let token = dto.data.toDomain()
            self?.set(token: token)
            return ()
        }
    }
    
    func get() -> Token? { //네트워킹 할때마다 사용됨
        guard let memberId = keyChainManager.get(key: "memberId") as? Int,
              let accessToken = keyChainManager.get(key: "accessToken") as? String,
              let refreshToken = keyChainManager.get(key: "refreshToken") as? String else {
            return nil
        }
        return Token(
            memberId: memberId,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
    
    func set(token: Token) { //최초, refreshToken 만료 시에만 사용됨
        keyChainManager.set(
            key: "memberId",
            value: token.memberId
        )
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
        keyChainManager.delete(key: "memberId")
        keyChainManager.delete(key: "accessToken")
        keyChainManager.delete(key: "refreshToken")
    }
}

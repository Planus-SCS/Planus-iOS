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
    
    func refresh() -> Single<Token>? {
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
        .map { // FIXME: 여기서 그냥 채우고 다시 디티오로 만듬... 이거 수정 무조건 해야한다..!
            var newToken = $0.data.toDomain()
            newToken.memberId = token.memberId
            return newToken
        }
    }
    
    func get() -> Token? { //네트워킹 할때마다 사용됨
        guard let memberId = keyChainManager.get(key: "memberId"),
              let accessToken = keyChainManager.get(key: "accessToken"),
              let refreshToken = keyChainManager.get(key: "refreshToken") else {
            return nil
        }
        let token = Token(
            memberId: Int(String(decoding: memberId as! Data, as: UTF8.self))!,
            accessToken: String(decoding: accessToken as! Data, as: UTF8.self),
            refreshToken: String(decoding: refreshToken as! Data, as: UTF8.self)
        )
        return token
    }
    
    func set(token: Token) { //최초, refreshToken 만료 시에만 사용됨
        keyChainManager.set(
            key: "memberId",
            value: String(token.memberId).data(using: .utf8, allowLossyConversion: false) as Any
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

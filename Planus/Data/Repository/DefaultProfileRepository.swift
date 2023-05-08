//
//  DefaultProfileRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

class DefaultProfileRepository: ProfileRepository {
    let apiProvider: NetworkManager
    
    init(apiProvider: NetworkManager) {
        self.apiProvider = apiProvider
    }
    
    func readProfile(token: Token) -> Single<ResponseDTO<ProfileResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.members,
            requestType: .get,
            body: nil,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<ProfileResponseDataDTO>.self
        )
    }
}

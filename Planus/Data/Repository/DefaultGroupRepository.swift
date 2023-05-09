//
//  DefaultGroupRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

class DefaultGroupRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func readGroup(token: String, id: Int) -> Single<ResponseDTO<UnJoinedGroupDetailResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.groups + "\(id)",
            requestType: .get,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<UnJoinedGroupDetailResponseDTO>.self
        )
    }
}

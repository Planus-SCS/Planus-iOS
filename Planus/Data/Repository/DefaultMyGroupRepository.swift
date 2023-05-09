//
//  DefaultMyGroupRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

class DefaultMyGroupRepository: MyGroupRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func create(token: String, groupCreateRequestDTO: GroupCreateRequestDTO, image: ImageFile) -> Single<ResponseDTO<GroupCreateResponseDTO>> {
        let endPoint = APIMultiPartEndPoint(
            url: URLPool.groups,
            requestType: .post,
            body: ["groupCreateRequestDto": groupCreateRequestDTO],
            image: ["image": image],
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestMultipartCodable(endPoint: endPoint, type: ResponseDTO<GroupCreateResponseDTO>.self)
    }
}

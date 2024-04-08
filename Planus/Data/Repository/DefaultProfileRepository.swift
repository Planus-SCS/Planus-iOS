//
//  DefaultProfileRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

final class DefaultProfileRepository: ProfileRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func readProfile(token: String) -> Single<ResponseDTO<ProfileResponseDataDTO>> {
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
    
    func updateProfile(token: String, requestDTO: ProfileRequestDTO, profileImage: ImageFile?) -> Single<ResponseDTO<ProfileResponseDataDTO>> {

        let endPoint = APIMultiPartEndPoint(
            url: URLPool.members,
            requestType: .patch,
            body: ["updateRequestDto": requestDTO],
            image: profileImage != nil ? ["image": profileImage!] : nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestMultipartCodable(
            endPoint: endPoint,
            type: ResponseDTO<ProfileResponseDataDTO>.self
        )
    }
    
    func removeProfile(token: String) -> Single<ResponseDTO<ProfileResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.members,
            requestType: .delete,
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



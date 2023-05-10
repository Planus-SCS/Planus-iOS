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
    
    func fetchJoinApplyList(token: String) -> Single<ResponseDTO<[GroupJoinAppliedResponseDTO]>> {
        let endPoint = APIEndPoint(
            url: URLPool.groupJoin,
            requestType: .get,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<[GroupJoinAppliedResponseDTO]>.self
        )
    }
    
    func acceptApply(token: String, applyId: Int) -> Single<ResponseDTO<GroupJoinAcceptResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.groupJoin + "/\(applyId)/accept",
            requestType: .post,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<GroupJoinAcceptResponseDTO>.self
        )
    }
    
    func denyApply(token: String, applyId: Int) -> Single<ResponseDTO<GroupJoinRejectResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.groupJoin + "/\(applyId)/reject",
            requestType: .post,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<GroupJoinRejectResponseDTO>.self
        )
    }
    
    func fetchGroupList(token: String) -> Single<ResponseDTO<[MyGroupSummaryResponseDTO]>> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup,
            requestType: .get,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<[MyGroupSummaryResponseDTO]>.self
        )
    }
}

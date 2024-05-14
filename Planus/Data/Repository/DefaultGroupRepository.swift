//
//  DefaultGroupRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

final class DefaultGroupRepository: GroupRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func fetchSearchHome(token: String, page: Int, size: Int) -> Single<ResponseDTO<[UnJoinedGroupSummaryResponseDTO]>> {
        let endPoint = APIEndPoint(
            url: URLPool.groups,
            requestType: .get,
            body: nil,
            query: [
                "page": String(page),
                "size": String(size)
            ],
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<[UnJoinedGroupSummaryResponseDTO]>.self
        )
    }
    
    func fetchSearchResult(token: String, keyWord: String, page: Int, size: Int) -> Single<ResponseDTO<[UnJoinedGroupSummaryResponseDTO]>> {
        let endPoint = APIEndPoint(
            url: URLPool.search,
            requestType: .get,
            body: nil,
            query: [
                "keyword": keyWord,
                "page": String(page),
                "size": String(size)
            ],
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<[UnJoinedGroupSummaryResponseDTO]>.self
        )
    }
    
    func fetchGroupDetail(token: String, id: Int) -> Single<ResponseDTO<UnJoinedGroupDetailResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.groups + "/\(id)",
            requestType: .get,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<UnJoinedGroupDetailResponseDTO>.self
        )
    }
    
    func fetchMemberList(token: String, id: Int) -> Single<ResponseDTO<[MemberDTO]>> {
        let endPoint = APIEndPoint(
            url: URLPool.groups + "/\(id)/members",
            requestType: .get,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<[MemberDTO]>.self
        )
    }
    
    func joinGroup(token: String, id: Int) -> Single<ResponseDTO<GroupJoinApplingResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.groupJoin + URLPathComponent.groups + "/\(id)",
            requestType: .post,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<GroupJoinApplingResponseDTO>.self
        )
    }
}

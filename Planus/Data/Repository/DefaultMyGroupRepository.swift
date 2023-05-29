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
    
    func withdrawGroup(token: String, groupId: Int) -> Single<ResponseDTO<GroupWithdrawResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.groups + "/\(groupId)/withdraw",
            requestType: .delete,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<GroupWithdrawResponseDTO>.self
        )
    }
    
    func removeGroup(token: String, groupId: Int) -> Single<ResponseDTO<GroupRemoveResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.groups + "/\(groupId)",
            requestType: .delete,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<GroupRemoveResponseDTO>.self
        )
    }
    
    func fetchGroupNameList(token: String) -> Single<ResponseDTO<[GroupNameResponseDTO]>> {
        let endPoint = APIEndPoint(
            url: URLPool.calendar + "/my-groups",
            requestType: .get,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<[GroupNameResponseDTO]>.self
        )
    }
    
    func fetchGroupSummaryList(token: String) -> Single<ResponseDTO<[MyGroupSummaryResponseDTO]>> {
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
    
    func fetchMyGroupDetail(token: String, groupId: Int) -> Single<ResponseDTO<MyGroupDetailResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)",
            requestType: .get,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<MyGroupDetailResponseDTO>.self
        )
    }
    
    func fetchMyGroupMemberList(token: String, groupId: Int) -> Single<ResponseDTO<[MyMemberResponseDTO]>> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/members",
            requestType: .get,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<[MyMemberResponseDTO]>.self
        )
    }
    
    func fetchMyGroupCalendar(token: String, groupId: Int, from: Date, to: Date) -> Single<ResponseDTO<[SocialTodoSummaryResponseDTO]>> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/todos/calendar",
            requestType: .get,
            body: nil,
            query: [
                "from": dateFormatter.string(from: from),
                "to": dateFormatter.string(from: to)
            ],
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<[SocialTodoSummaryResponseDTO]>.self
        )
    }
    
    func updateInfo(token: String, groupId: Int, editRequestDTO: MyGroupInfoEditRequestDTO, image: ImageFile) -> Single<ResponseDTO<MyGroupInfoEditResponseDTO>> {
        let endPoint = APIMultiPartEndPoint(
            url: URLPool.groups + "/\(groupId)",
            requestType: .patch,
            body: ["groupUpdateRequestDto": editRequestDTO],
            image: ["image": image],
            query: nil,
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.requestMultipartCodable(
            endPoint: endPoint,
            type: ResponseDTO<MyGroupInfoEditResponseDTO>.self
        )
    }
    
    func updateNotice(token: String, groupId: Int, notice: MyGroupNoticeEditRequestDTO) -> Single<ResponseDTO<MyGroupNoticeEditResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.groups + "/\(groupId)/notice",
            requestType: .patch,
            body: notice,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<MyGroupNoticeEditResponseDTO>.self
        )
    }
    
    func kickOutMember(token: String, groupId: Int, memberId: Int) -> Single<ResponseDTO<MyMemberKickOutResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.groups + "/\(groupId)/members/\(memberId)",
            requestType: .delete,
            body: nil,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<MyMemberKickOutResponseDTO>.self
        )
    }
    
    func changeOnlineState(token: String, groupId: Int) -> Single<ResponseDTO<GroupSetOnlineResponseDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/online-status",
            requestType: .patch,
            body: nil,
            query: nil,
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<GroupSetOnlineResponseDTO>.self
        )
    }
}

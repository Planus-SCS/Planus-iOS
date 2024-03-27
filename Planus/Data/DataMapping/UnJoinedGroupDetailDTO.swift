//
//  UnJoinedGroupDetailDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation

struct UnJoinedGroupSummaryResponseDTO: Codable {
    var groupId: Int
    var name: String
    var groupImageUrl: String
    var memberCount: Int
    var limitCount: Int
    var leaderId: Int
    var leaderName: String
    var groupTags: [GroupTagResponseDTO]
}

extension UnJoinedGroupSummaryResponseDTO {
    func toDomain() -> GroupSummary {
        return GroupSummary(
            groupId: groupId,
            name: name,
            groupImageUrl: groupImageUrl,
            memberCount: memberCount,
            limitCount: limitCount,
            leaderId: leaderId,
            leaderName: leaderName,
            groupTags: groupTags.map { $0.toDomain() }
        )
    }
}

struct UnJoinedGroupDetailResponseDTO: Codable {
    var id: Int
    var name: String
    var isJoined: Bool
    var notice: String
    var groupImageUrl: String
    var memberCount: Int
    var limitCount: Int
    var leaderName: String
    var groupTags: [GroupTagResponseDTO]
}

extension UnJoinedGroupDetailResponseDTO {
    func toDomain() -> GroupDetail {
        return GroupDetail(
            id: id,
            name: name,
            isJoined: isJoined,
            notice: notice,
            groupImageUrl: groupImageUrl,
            memberCount: memberCount,
            limitCount: limitCount,
            leaderName: leaderName,
            groupTags: groupTags.map { $0.toDomain() }
        )
    }
}


//
//  GroupJoinApplyDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation

struct GroupJoinAppliedResponseDTO: Codable {
    var groupJoinId: Int
    var groupId: Int
    var groupName: String
    var memberId: Int
    var memberName: String
    var memberDescription: String?
    var memberProfileImageUrl: String?
    var acceptStatus: String
}

extension GroupJoinAppliedResponseDTO {
    func toDomain() -> GroupJoinApplied {
        return GroupJoinApplied(
            groupJoinId: groupJoinId,
            groupId: groupId,
            groupName: groupName,
            memberId: memberId,
            memberName: memberName,
            memberDescription: memberDescription,
            memberProfileImageUrl: memberProfileImageUrl
        )
    }
}

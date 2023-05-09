//
//  GroupJoinApplyDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation

struct GroupJoinApplyResponseDTO: Codable {
    var groupJoinId: Int
    var groupId: Int
    var groupName: String
    var memberId: Int
    var memberName: String
    var memberDescription: String?
    var memberProfileImageUrl: String?
    var acceptStatus: String
}

extension GroupJoinApplyResponseDTO {
    func toDomain() -> GroupJoinApply {
        return GroupJoinApply(
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

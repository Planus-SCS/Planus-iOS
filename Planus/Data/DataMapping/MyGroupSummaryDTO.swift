//
//  MyGroupSummaryDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation

struct MyGroupSummaryResponseDTO: Codable {
    var groupId: Int
    var groupImageUrl: String
    var groupName: String
    var isOnline: Bool
    var onlineCount: Int
    var memberCount: Int
    var limitCount: Int
    var leaderName: String
    var groupTags: [GroupTagResponseDTO]
}

extension MyGroupSummaryResponseDTO {
    func toDomain() -> MyGroupSummary {
        return MyGroupSummary(
            groupId: groupId,
            groupImageUrl: groupImageUrl,
            groupName: groupName,
            isOnline: isOnline,
            onlineCount: onlineCount,
            totalCount: memberCount,
            limitCount: limitCount,
            leaderName: leaderName,
            groupTags: groupTags.map { $0.toDomain() }
        )
    }
}

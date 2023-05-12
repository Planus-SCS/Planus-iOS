//
//  MyGroupDetailDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation

struct MyGroupDetailResponseDTO: Codable {
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

extension MyGroupDetailResponseDTO {
    func toDomain() -> MyGroupDetail {
        return MyGroupDetail(
            groupId: groupId,
            groupImageUrl: groupImageUrl,
            groupName: groupName,
            isOnline: isOnline,
            onlineCount: onlineCount,
            memberCount: memberCount,
            limitCount: limitCount,
            leaderName: leaderName,
            groupTags: groupTags.map { $0.toDomain() }
        )
    }
}

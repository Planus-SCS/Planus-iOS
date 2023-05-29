//
//  GroupNameDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/17.
//

import Foundation

struct GroupNameResponseDTO: Codable {
    var groupId: Int
    var groupName: String
}

extension GroupNameResponseDTO {
    func toDomain() -> GroupName {
        return GroupName(groupId: groupId, groupName: groupName)
    }
}

//
//  GroupCreate.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation

struct GroupCreate {
    var name: String
    var notice: String
    var tagList: [GroupTag]
    var limitCount: Int
}

extension GroupCreate {
    func toDTO() -> GroupCreateRequestDTO {
        return GroupCreateRequestDTO(
            name: name,
            notice: notice,
            tagList: tagList.map { $0.toDTO() },
            limitCount: limitCount
        )
    }
}

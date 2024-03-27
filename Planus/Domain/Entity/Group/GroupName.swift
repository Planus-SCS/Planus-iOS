//
//  GroupName.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/17.
//

import Foundation

struct GroupName {
    var groupId: Int
    var groupName: String
}

extension GroupName: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.groupId == rhs.groupId
    }
}

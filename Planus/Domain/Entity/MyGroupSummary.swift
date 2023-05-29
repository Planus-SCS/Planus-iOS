//
//  MyGroupSummary.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation

struct MyGroupSummary {
    var groupId: Int
    var groupImageUrl: String
    var groupName: String
    var isOnline: Bool
    var onlineCount: Int
    var totalCount: Int
    var limitCount: Int
    var leaderName: String
    var groupTags: [GroupTag]
}

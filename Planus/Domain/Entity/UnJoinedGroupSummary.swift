//
//  UnJoinedGroupSummary.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

struct UnJoinedGroupSummary {
    var groupId: Int
    var name: String
    var groupImageUrl: String
    var memberCount: Int
    var limitCount: Int
    var leaderId: Int
    var leaderName: String
    var groupTags: [GroupTag]
}

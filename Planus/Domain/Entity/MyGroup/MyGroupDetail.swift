//
//  MyGroupDetail.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation

struct MyGroupDetail {
    var groupId: Int
    var groupImageUrl: String
    var groupName: String
    var isLeader: Bool
    var isOnline: Bool
    var onlineCount: Int
    var memberCount: Int
    var limitCount: Int
    var leaderName: String
    var notice: String
    var groupTags: [GroupTag]
}

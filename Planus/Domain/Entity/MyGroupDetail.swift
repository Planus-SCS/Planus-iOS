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
    var isOnline: Bool
    var onlineCount: Int
    var memberCount: Int
    var limitCount: Int
    var leaderName: String
    var groupTags: [GroupTag]
}

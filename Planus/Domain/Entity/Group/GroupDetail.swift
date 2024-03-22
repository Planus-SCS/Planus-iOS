//
//  GroupDetail.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation

struct GroupDetail {
    var id: Int
    var name: String
    var isJoined: Bool
    var notice: String
    var groupImageUrl: String
    var memberCount: Int
    var limitCount: Int
    var leaderName: String
    var groupTags: [GroupTag]
}

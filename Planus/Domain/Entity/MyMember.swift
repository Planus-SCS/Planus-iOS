//
//  MyMember.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation

struct MyMember: Codable {
    var memberId: Int
    var nickname: String
    var isLeader: Bool
    var isOnline: Bool
    var description: String?
    var profileImageUrl: String?
}

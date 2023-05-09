//
//  MemberDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation

struct MemberDTO: Codable {
    var memberId: Int
    var nickname: String
    var isLeader: Bool
    var description: String?
    var profileImageUrl: String?
}

extension MemberDTO {
    func toDomain() -> Member {
        return Member(
            id: memberId,
            name: nickname,
            isLeader: isLeader,
            description: description,
            profileImageUrl: profileImageUrl
        )
    }
}

//
//  MyMemberDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation

struct MyMemberResponseDTO: Codable {
    var memberId: Int
    var nickname: String
    var isLeader: Bool
    var isOnline: Bool
    var description: String?
    var profileImageUrl: String?
}

extension MyMemberResponseDTO {
    func toDomain() -> MyMember {
        return MyMember(
            memberId: memberId,
            nickname: nickname,
            isLeader: isLeader,
            isOnline: isOnline,
            description: description,
            profileImageUrl: profileImageUrl
        )
    }
}

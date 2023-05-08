//
//  ProfileResponseDataDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation

struct ProfileResponseDataDTO: Codable {
    var memberId: Int
    var nickname: String
    var description: String?
    var profileImageUrl: String?
}

extension ProfileResponseDataDTO {
    func toDomain() -> Profile {
        return Profile(
            id: memberId,
            nickName: nickname,
            description: description,
            imageUrl: profileImageUrl
        )
    }
}

struct ProfileRequestDTO: Codable {
    var nickname: String
    var description: String?
}

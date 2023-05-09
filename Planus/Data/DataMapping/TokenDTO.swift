//
//  TokenDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation

struct TokenRequestDTO: Codable {
    var accessToken: String
    var refreshToken: String
}

struct TokenResponseDataDTO: Codable {
    var memberId: Int
    var accessToken: String
    var refreshToken: String
}

struct TokenRefreshResponseDataDTO: Codable {
    var accessToken: String
    var refreshToken: String
}

extension TokenResponseDataDTO {
    func toDomain() -> Token {
        return Token(
            memberId: memberId,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}

extension TokenRefreshResponseDataDTO {
    func toDomain() -> Token {
        return Token(
            memberId: 0,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}

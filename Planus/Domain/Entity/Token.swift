//
//  Token.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

struct Token {
    var memberId: Int
    var accessToken: String
    var refreshToken: String
}

extension Token {
    func toDTO() -> TokenRequestDTO {
        return TokenRequestDTO(
            memberId: memberId,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}

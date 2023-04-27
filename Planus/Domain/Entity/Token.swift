//
//  Token.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

struct Token: Codable {
    var accessToken: String
    var refreshToken: String
}

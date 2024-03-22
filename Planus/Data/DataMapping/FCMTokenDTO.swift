//
//  FCMTokenDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/09/07.
//

import Foundation

struct FCMTokenRequestDTO: Codable {
    var fcmToken: String
}

struct FCMTokenResponseDTO: Codable {
    var fcmTokenId: Int
}

//
//  AppleSignInDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation

struct AppleSignInRequestDTO: Codable {
    var identityToken: String
    var fullName: PersonNameComponents?
}

struct AppleIDTokenResponseDTO: Codable {
    
    var access_token: String
    var token_type: String
    var expires_in: Int
    var refresh_token: String
    var id_token: String
    
}

struct AppleClientSecret: Codable {
    var clientSecret: String
}

//
//  MyGroupNoticeEditDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation

struct MyGroupNoticeEditRequestDTO: Codable {
    var notice: String
}

struct MyGroupNoticeEditResponseDTO: Codable {
    var groupId: Int
}

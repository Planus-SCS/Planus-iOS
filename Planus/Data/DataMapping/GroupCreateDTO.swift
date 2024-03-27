//
//  GroupCreateDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation

struct GroupCreateRequestDTO: Codable {
    var name: String
    var notice: String
    var tagList: [GroupTagRequestDTO]
    var limitCount: Int
}

struct GroupCreateResponseDTO: Codable {
    var groupId: Int
}

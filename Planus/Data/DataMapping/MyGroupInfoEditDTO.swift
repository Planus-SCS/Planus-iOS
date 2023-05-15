//
//  MyGroupInfoEditDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import Foundation

struct MyGroupInfoEditRequestDTO: Codable {
    var tagList: [GroupTagRequestDTO]
    var limitCount: Int
}

struct MyGroupInfoEditResponseDTO: Codable {
    var groupId: Int
}

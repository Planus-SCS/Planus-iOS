//
//  GroupTagDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation

struct GroupTagRequestDTO: Codable {
    var name: String
}

struct GroupTagResponseDTO: Codable {
    var id: Int
    var name: String
}

extension GroupTagResponseDTO {
    func toDomain() -> GroupTag {
        return GroupTag(id: id, name: name)
    }
}

extension GroupTag {
    func toDTO() -> GroupTagRequestDTO {
        return GroupTagRequestDTO(name: name)
    }
}

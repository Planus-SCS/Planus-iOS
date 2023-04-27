//
//  TodoCategoryDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

// MARK: CREATE, UPDATE
struct TodoCategoryRequestDTO: Codable {
    var title: String
    var color: String
    
    init(title: String, color: String) {
        self.title = title
        self.color = color
    }
}

// MARK: CREATE, UPDATE, DELETE
struct TodoCategoryResponseDTO: Codable {
    var isSuccess: Bool
    var code: Int
    var data: TodoCategoryResponseDataDTO
}

struct TodoCategoryResponseDataDTO: Codable {
    var id: Int
}

struct TodoCategoryListResponseDTO: Codable {
    var isSuccess: Bool
    var code: Int
    var message: String
    var data: [TodoCategoryEntityResponseDTO]
}

// MARK: READ
struct TodoCategoryEntityResponseDTO: Codable {
    var id: Int
    var title: String
    var color: String
    
    init(id: Int, title: String, color: String) {
        self.id = id
        self.title = title
        self.color = color
    }
    
    func toDomain() -> TodoCategory {
        return TodoCategory(
            id: self.id,
            title: self.title,
            color: TodoCategoryColor(rawValue: self.color) ?? .none
        )
    }
}

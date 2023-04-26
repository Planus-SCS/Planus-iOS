//
//  TodoCategoryColor.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation

enum TodoCategoryColor: String, CaseIterable {
    case blue = "BLUE"
    case gold = "GOLD"
    case pink = "PINK"
    case purple = "PURPLe"
    case green = "GREEN"
    case navy = "NAVY"
    case red = "RED"
    case yello = "YELLO"
    case none = "NONE"
}

struct TodoCategory {
    var id: Int?
    var title: String
    var color: TodoCategoryColor
    
    init(id: Int, title: String, color: TodoCategoryColor) {
        self.id = id
        self.title = title
        self.color = color
    }
    
    func toCreateDTO() -> TodoCategoryCreateRequestDTO {
        return TodoCategoryCreateRequestDTO(
            title: self.title,
            color: self.color.rawValue
        )
    }
    
    func toUpdateDTO() -> TodoCategoryUpdateRequestDTO {
        return TodoCategoryUpdateRequestDTO(
            id: self.id ?? Int(),
            title: self.title,
            color: self.color.rawValue
        )
    }
}

struct TodoCategoryCreateRequestDTO: Codable {
    var title: String
    var color: String
    
    init(title: String, color: String) {
        self.title = title
        self.color = color
    }
}

struct TodoCategoryCreateResponseDTO: Codable {
    var isSuccess: Bool
    var code: Int
    var data: TodoCategoryCreateResponseDataDTO
}

struct TodoCategoryCreateResponseDataDTO: Codable {
    var id: Int
}

struct TodoCategoryUpdateRequestDTO: Codable {
    var title: String
    var color: String
    
    init(title: String, color: String) {
        self.title = title
        self.color = color
    }
}

struct TodoCategoryUpdateResponseDTO: Codable {
    var isSuccess: Bool
    var code: Int
    var data: TodoCategoryCreateResponseDataDTO
}

struct TodoCategoryUpdateResponseDataDTO: Codable {
    var id: Int
}

struct TodoCategoryReadResponseDTO: Codable {
    var isSuccess: Bool
    var code: Int
    var message: String
    var data: [TodoCategoryReadResponseDateDTO]
}

struct TodoCategoryReadResponseDateDTO: Codable {
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

struct TodoCategoryDeleteResponseDTO: Codable {
    var isSuccess: Bool
    var code: Int
    var message: String
    var data: TodoCategoryDeleteResponseDataDTO
}

struct TodoCategoryDeleteResponseDataDTO: Codable {
    var id: Int
}

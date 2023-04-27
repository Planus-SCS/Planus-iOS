//
//  TodoCategoryDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

// MARK: CREATE, UPDATE
struct CategoryRequestDTO: Codable {
    var title: String
    var color: String
    
    init(title: String, color: String) {
        self.title = title
        self.color = color
    }
}

struct CategoryResponseDataDTO: Codable {
    var id: Int
}

// MARK: READ
struct CategoryEntityResponseDTO: Codable {
    var id: Int
    var title: String
    var color: String
    
    init(id: Int, title: String, color: String) {
        self.id = id
        self.title = title
        self.color = color
    }
    
    func toDomain() -> Category {
        return Category(
            id: self.id,
            title: self.title,
            color: CategoryColor(rawValue: self.color) ?? .none
        )
    }
}

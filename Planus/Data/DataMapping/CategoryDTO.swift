//
//  TodoCategoryDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

// MARK: CREATE, UPDATE
struct CategoryRequestDTO: Codable {
    var name: String
    var color: String
    
    init(name: String, color: String) {
        self.name = name
        self.color = color
    }
}

struct CategoryResponseDataDTO: Codable {
    var id: Int
}

// MARK: READ
struct CategoryEntityResponseDTO: Codable {
    var id: Int
    var name: String
    var color: String
    var status: String
    
    init(id: Int, name: String, color: String, status: String) {
        self.id = id
        self.name = name
        self.color = color
        self.status = status
    }
    
    func toDomain() -> Category {
        return Category(
            id: self.id,
            title: self.name,
            color: CategoryColor(rawValue: self.color) ?? .none,
            status: CategoryStatus(rawValue: status)
        )
    }
}

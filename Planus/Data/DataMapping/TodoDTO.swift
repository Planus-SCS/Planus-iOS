//
//  TodoDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

// MARK: CREATE, UPDATE
struct TodoRequestDTO: Codable {
    var title: String
    var categoryId: Int
    var startDate: String
    var endDate: String
    var startTime: String?
    var description: String?
    
    init(
        title: String,
        categoryId: Int,
        startDate: String,
        endDate: String,
        startTime: String?,
        description: String?
    ) {
        self.title = title
        self.categoryId = categoryId
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.description = description
    }
}

struct TodoEntityResponseDTO: Codable {
    var id: Int
    var title: String
    var startDate: Date?
    var endDate: Date?
    var memo: String?
    var group: GroupResponseDTO?
    var category: TodoCategoryEntityResponseDTO?
    var startTime: String?
    
    init(
        id: Int,
        title: String,
        startDate: Date,
        endDate: Date?,
        memo: String?,
        group: GroupResponseDTO?,
        category: TodoCategoryEntityResponseDTO?,
        startTime: String?
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.memo = memo
        self.group = group
        self.category = category
        self.startTime = startTime
    }
}

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
    var groupId: Int?
    var startDate: String
    var endDate: String
    var startTime: String?
    var description: String?
    
    init(
        title: String,
        categoryId: Int,
        groupId: Int?,
        startDate: String,
        endDate: String,
        startTime: String?,
        description: String?
    ) {
        self.title = title
        self.categoryId = categoryId
        self.groupId = groupId
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.description = description
    }
}

struct TodoEntityResponseDTO: Codable {
    var todoId: Int
    var title: String
    var categoryId: Int
    var groupId: Int?
    var startDate: Date?
    var endDate: Date?
    var startTime: String?
    var description: String?
    
    init(
        todoId: Int,
        title: String,
        categoryId: Int,
        groupId: Int?,
        startDate: Date?,
        endDate: Date?,
        startTime: String?,
        description: String?
    ) {
        self.todoId = todoId
        self.title = title
        self.categoryId = categoryId
        self.groupId = groupId
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.description = description
    }
}

struct TodoResponseDataDTO: Codable {
    var todoId: Int
}

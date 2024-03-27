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
    var startDate: String
    var endDate: String
    var startTime: String?
    var description: String?
    var isCompleted: Bool?
}

struct TodoListResponseDTO: Codable { //그룹 isGroupTodo냐 아니냐로 판단하자..!
    var memberTodos: [TodoEntityResponseDTO]
    var groupTodos: [TodoEntityResponseDTO]
}

extension TodoEntityResponseDTO {
    func toDomain(isGroup: Bool) -> Todo {
        return Todo(
            id: todoId,
            title: title,
            startDate: startDate.toDate() ?? Date(),
            endDate: endDate.toDate() ?? Date(),
            memo: description,
            groupId: groupId,
            categoryId: categoryId,
            startTime: startTime,
            isCompleted: isCompleted,
            isGroupTodo: isGroup
        )
    }
}

struct TodoResponseDataDTO: Codable {
    var todoId: Int
}

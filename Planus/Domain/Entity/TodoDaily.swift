//
//  TodoDaily.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

struct TodoDailyListResponseDTO: Codable {
    var isSuccess: Bool
    var code: Int
    var message: String
    var data: TodoDailyListDataResponseDTO
}

struct TodoDailyListDataResponseDTO: Codable {
    var dailySchedules: [TodoDailyResponseDTO]
    var dailyTodos: [TodoDailyResponseDTO]
}

struct TodoDailyResponseDTO: Codable {
    var id: Int
    var title: String
    var startTime: String
    var isGroupMemberTodo: Bool
    var isPeriodTodo: Bool
    var hasDescription: Bool
    
    func toDomain() -> TodoDaily {
        return TodoDaily(
            id: self.id,
            title: self.title,
            startTime: self.startTime,
            isGroupMemberTodo: self.isGroupMemberTodo,
            isPeriodTodo: self.isPeriodTodo,
            hasDescription: self.hasDescription
        )
    }
}

struct TodoDaily {
    var id: Int
    var title: String
    var startTime: String
    var isGroupMemberTodo: Bool
    var isPeriodTodo: Bool
    var hasDescription: Bool
}

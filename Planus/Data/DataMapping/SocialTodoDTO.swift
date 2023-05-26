//
//  SocialTodoDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation

struct SocialTodoSummaryResponseDTO: Codable {
    var todoId: Int
    var categoryColor: String
    var title: String
    var startDate: String
    var endDate: String
}

extension SocialTodoSummaryResponseDTO {
    func toDomain() -> SocialTodoSummary {
        return SocialTodoSummary(
            todoId: todoId,
            categoryColor: CategoryColor(rawValue: categoryColor) ?? .none,
            title: title,
            startDate: startDate.toDate() ?? Date(),
            endDate: endDate.toDate() ?? Date()
        )
    }
}

struct SocialTodoDailyListResponseDTO: Codable {
    var dailySchedules: [SocialTodoDailyResponseDTO]
    var dailyTodos: [SocialTodoDailyResponseDTO]
}

struct SocialTodoDailyResponseDTO: Codable {
    var todoId: Int
    var categoryColor: String
    var title: String
    var startTime: String
    var hasGroup: Bool
    var isPeriodTodo: Bool
    var hasDescription: Bool
    var isCompleted: Bool
}

extension SocialTodoDailyResponseDTO {
    func toDomain() -> SocialTodoDaily {
        return SocialTodoDaily(
            todoId: todoId,
            categoryColor: CategoryColor(rawValue: categoryColor) ?? .none,
            title: title,
            startTime: startTime,
            hasGroup: hasGroup,
            isPeriodTodo: isPeriodTodo,
            hasDescription: hasDescription,
            isCompleted: isCompleted
        )
    }
}

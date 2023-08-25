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
    var startTime: String?
    var isGroupTodo: Bool
    var isPeriodTodo: Bool
    var hasDescription: Bool
    var isCompleted: Bool?
}

extension SocialTodoDailyResponseDTO {
    func toDomain() -> SocialTodoDaily {
        return SocialTodoDaily(
            todoId: todoId,
            categoryColor: CategoryColor(rawValue: categoryColor) ?? .none,
            title: title,
            startTime: startTime,
            isGroupTodo: isGroupTodo,
            isPeriodTodo: isPeriodTodo,
            hasDescription: hasDescription,
            isCompleted: isCompleted
        )
    }
}

struct SocialTodoDetailResponseDTO: Codable {
    var todoId: Int
    var title: String
    var todoCategory: SocialCategoryResponseDTO
    var groupName: String
    var startDate: String
    var endDate: String?
    var startTime: String?
    var description: String?
}

extension SocialTodoDetailResponseDTO {
    func toDomain() -> SocialTodoDetail {
        return SocialTodoDetail(
            todoId: todoId,
            title: title,
            todoCategory: todoCategory.toDomain(),
            groupName: groupName,
            startDate: startDate.toDate() ?? Date(),
            endDate: endDate?.toDate(),
            startTime: startTime,
            description: description
        )
    }
}

struct SocialCategoryResponseDTO: Codable {
    var todoCategoryId: Int
    var name: String
    var color: String
}

extension SocialCategoryResponseDTO {
    func toDomain() -> SocialCategory {
        return SocialCategory(id: todoCategoryId, name: self.name, color: CategoryColor(rawValue: self.color) ?? .none)
    }
}

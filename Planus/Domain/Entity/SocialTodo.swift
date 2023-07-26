//
//  SocialTodo.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation

struct SocialTodoSummary {
    var todoId: Int
    var categoryColor: CategoryColor
    var title: String
    var startDate: Date
    var endDate: Date
}

struct SocialTodoDaily {
    var todoId: Int
    var categoryColor: CategoryColor
    var title: String
    var startTime: String?
    var isGroupTodo: Bool
    var isPeriodTodo: Bool
    var hasDescription: Bool
    var isCompleted: Bool?
}

struct SocialTodoDetail {
    var todoId: Int
    var title: String
    var todoCategory: SocialCategory
    var groupName: String
    var startDate: Date
    var endDate: Date?
    var startTime: String?
    var description: String?
}

struct SocialCategory {
    var name: String
    var color: CategoryColor
}

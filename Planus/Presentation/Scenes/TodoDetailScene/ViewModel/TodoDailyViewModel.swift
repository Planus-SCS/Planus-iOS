//
//  TodoDailyViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import Foundation

struct TodoDailyViewModel {
    var todoId: Int
    var categoryColor: CategoryColor
    var title: String
    var startTime: String?
    var isGroupTodo: Bool
    var isPeriodTodo: Bool
    var hasDescription: Bool
    var isCompleted: Bool?
}

extension SocialTodoDaily {
    func toViewModel() -> TodoDailyViewModel {
        return TodoDailyViewModel(
            todoId: todoId,
            categoryColor: categoryColor,
            title: title,
            startTime: startTime,
            isGroupTodo: isGroupTodo,
            isPeriodTodo: isPeriodTodo,
            hasDescription: hasDescription
        )
    }
}

extension Todo {
    func toDailyViewModel(color: CategoryColor) -> TodoDailyViewModel {
        return TodoDailyViewModel(
            todoId: self.id!,
            categoryColor: color,
            title: self.title,
            startTime: self.startTime,
            isGroupTodo: self.isGroupTodo,
            isPeriodTodo: self.startDate != self.endDate,
            hasDescription: self.memo != nil
        )
    }
}

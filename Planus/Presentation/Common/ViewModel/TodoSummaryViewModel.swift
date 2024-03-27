//
//  TodoSummaryViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 3/19/24.
//

import Foundation

struct TodoSummaryViewModel {
    var todoId: Int
    var categoryColor: CategoryColor
    var title: String
    var startDate: Date
    var endDate: Date
    var isCompleted: Bool?
}

extension Todo {
    func toViewModel(color: CategoryColor) -> TodoSummaryViewModel {
        return TodoSummaryViewModel(
            todoId: self.id ?? Int(),
            categoryColor: color,
            title: self.title,
            startDate: self.startDate,
            endDate: self.endDate,
            isCompleted: self.isCompleted
        )
    }
}

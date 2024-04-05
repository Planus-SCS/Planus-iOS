//
//  TodoDetail.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import Foundation

struct TodoDetail {
    var id: Int?
    var title: String
    var startDate: Date
    var endDate: Date
    var memo: String?
    var group: GroupName?
    var category: Category?
    var startTime: String?
    var isCompleted: Bool?
    var isGroupTodo: Bool
}

extension TodoDetail {
    func toTodo() -> Todo {
        return Todo(
            id: id,
            title: title,
            startDate: startDate,
            endDate: endDate,
            memo: memo,
            groupId: group?.groupId,
            categoryId: category?.id ?? Int(),
            startTime: startTime,
            isCompleted: isCompleted,
            isGroupTodo: isGroupTodo
        )
    }
}

extension Todo {
    func toDetail(groups: [Int: GroupName], categories: [Int: Category]) -> TodoDetail {
        var group: GroupName? = {
            guard let groupId = self.groupId else { return nil }
            return groups[groupId]
        }()
        
        var category: Category? = categories[categoryId]
        
        return TodoDetail(
            id: self.id,
            title: self.title,
            startDate: self.startDate,
            endDate: self.endDate,
            memo: self.memo,
            group: group,
            category: category,
            startTime: self.startTime,
            isCompleted: self.isCompleted,
            isGroupTodo: self.isGroupTodo
        )
    }
}

//
//  Todo.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation

struct Todo {
    var id: Int?
    var title: String
    var startDate: Date
    var endDate: Date
    var memo: String?
    var groupId: Int?
    var categoryId: Int
    var startTime: String?
    
    init(
        id: Int,
        title: String,
        startDate: Date,
        endDate: Date,
        memo: String?,
        groupId: Int?,
        categoryId: Int,
        startTime: String?
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.memo = memo
        self.groupId = groupId
        self.categoryId = categoryId
        self.startTime = startTime
    }
}

extension Todo {
    func toDTO() -> TodoRequestDTO {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        
        return TodoRequestDTO(
            title: title,
            categoryId: categoryId,
            groupId: groupId,
            startDate: dateFormatter.string(from: startDate),
            endDate: dateFormatter.string(from: endDate),
            startTime: startTime,
            description: memo
        )
    }
}

//
//  Todo.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation

struct Todo {
    var id: Int
    var title: String
    var startDate: Date
    var endDate: Date
    var memo: String?
    var group: Group?
    var category: TodoCategory?
    var startTime: String?
    
    init(
        id: Int,
        title: String,
        startDate: Date,
        endDate: Date,
        memo: String?,
        group: Group?,
        category: TodoCategory?,
        startTime: String?
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.memo = memo
        self.group = group
        self.category = category
        self.startTime = startTime
    }
}


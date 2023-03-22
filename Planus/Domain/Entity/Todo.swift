//
//  Todo.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation

struct Todo {
    var id: String
    var title: String
    var date: Date
    var category: TodoCategory
    var type: TodoType
    var time: String?
    
    init(title: String, date: Date, category: TodoCategory, type: TodoType, time: String? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.date = date
        self.category = category
        self.type = type
        self.time = time
    }
}

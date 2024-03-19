//
//  SocialTodo.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation

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

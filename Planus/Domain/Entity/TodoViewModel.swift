//
//  TodoViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/03.
//

import Foundation

struct TodoViewModel {
    var id: Int?
    var title: String
    var startDate: Date
    var endDate: Date
    var memo: String?
    var group: Group?
    var category: Category
    var startTime: String?
    
    init(
        id: Int?,
        title: String,
        startDate: Date,
        endDate: Date,
        memo: String?,
        group: Group?,
        category: Category,
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

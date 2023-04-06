//
//  TodoCategoryColor.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation

enum TodoCategoryColor: Int, CaseIterable {
    case blue = 0
    case gold
    case pink
    case purple
    case green
    case navy
    case red
    case yello
    case none
}

struct TodoCategory {
    var title: String
    var color: TodoCategoryColor
}

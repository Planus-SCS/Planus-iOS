//
//  TodoCategory.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

struct TodoCategory {
    var id: Int?
    var title: String
    var color: TodoCategoryColor
    
    init(id: Int, title: String, color: TodoCategoryColor) {
        self.id = id
        self.title = title
        self.color = color
    }
}

extension TodoCategory {
    func toDTO() -> TodoCategoryRequestDTO {
        return TodoCategoryRequestDTO(
            title: self.title,
            color: self.color.rawValue
        )
    }
}

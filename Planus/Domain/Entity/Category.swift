//
//  Category.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

struct Category {
    var id: Int?
    var title: String
    var color: CategoryColor
    
    init(id: Int, title: String, color: CategoryColor) {
        self.id = id
        self.title = title
        self.color = color
    }
}

extension Category {
    func toDTO() -> CategoryRequestDTO {
        return CategoryRequestDTO(
            title: self.title,
            color: self.color.rawValue
        )
    }
}

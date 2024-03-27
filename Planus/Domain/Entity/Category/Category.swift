//
//  Category.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

enum CategoryStatus: String {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
}

struct Category {
    var id: Int?
    var title: String
    var color: CategoryColor
    var status: CategoryStatus?
}

extension Category {
    func toDTO() -> CategoryRequestDTO {
        return CategoryRequestDTO(
            name: self.title,
            color: self.color.rawValue
        )
    }
}

extension Category: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

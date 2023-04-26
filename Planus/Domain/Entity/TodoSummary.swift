//
//  TodoSummary.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation

struct TodoSummaryListResponseDTO: Codable {
    var isSuccess: Bool
    var code: Int
    var message: String
    var data: [TodoSummaryResponseDTO]
}

struct TodoSummaryResponseDTO: Codable {
    var id: Int
    var categoryId: Int
    var startDate: String
    var endDate: String
    
    func toDomain() -> TodoSummary {
        return TodoSummary(
            id: self.id,
            categoryId: self.categoryId,
            startDate: self.startDate.toDate(),
            endDate: self.endDate.toDate()
        )
    }
}

struct TodoSummary {
    var id: Int
    var categoryId: Int
    var startDate: Date?
    var endDate: Date?
}

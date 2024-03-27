//
//  FailureDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/27.
//

import Foundation

struct FailureDTO: Codable {
    var isSuccess: Bool
    var code: Int
    var message: String
}

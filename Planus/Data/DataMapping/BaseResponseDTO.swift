//
//  BaseResponseDTO.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation

struct ResponseDTO<T: Codable>: Codable {
    var isSuccess: Bool
    var code: Int
    var message: String
    var data: T
}

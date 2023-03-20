//
//  ApiEndPoint.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import Foundation

struct ApiEndPoint {
    let url: String
    let requestType: RequestType
    let body: Codable?
    let query: [String: String]?
    let header: [String: String]?
}

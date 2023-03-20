//
//  APIEndPoint.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation

struct APIEndPoint {
    let url: String
    let requestType: APIRequestType
    let body: Codable?
    let query: [String: String]?
    let header: [String: String]?
}

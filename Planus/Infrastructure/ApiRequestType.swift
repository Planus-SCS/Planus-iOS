//
//  ApiRequestType.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import Foundation

enum ApiRequestType: String { //연관값으로 리퀘스트 타입에 집어넣을 순 없나?
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

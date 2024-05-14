//
//  APIProvider.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

protocol APIProvider {
    func request<T: Codable>(endPoint: APIEndPoint, type: T.Type) -> Single<T>
    func request(endPoint: APIEndPoint) -> Single<Data>
    func request<T: Codable>(endPoint: APIMultiPartEndPoint, type: T.Type) -> Single<T>
    func request(endPoint: APIMultiPartEndPoint) -> Single<Data>
}

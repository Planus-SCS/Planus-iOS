//
//  APIProvider.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

protocol APIProvider {
    func requestCodable<T: Codable>(endPoint: APIEndPoint, type: T.Type) -> Single<T>
    func requestData(endPoint: APIEndPoint) -> Single<Data>
    func requestMultipartCodable<T: Codable>(endPoint: APIMultiPartEndPoint, type: T.Type) -> Single<T>
    func requestMultipartData(endPoint: APIMultiPartEndPoint) -> Single<Data>
}

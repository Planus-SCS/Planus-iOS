//
//  NetworkManager.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/20.
//

import Foundation
import RxSwift

protocol NetworkManager {
    func requestData(endPoint: ApiEndPoint) -> Single<Data>
    func requestCodable<T: Codable>(endPoint: ApiEndPoint, type: T.Type) -> Single<T>
}

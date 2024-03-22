//
//  ExecuteWithTokenUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 3/22/24.
//

import Foundation
import RxSwift

protocol ExecuteWithTokenUseCase {
    func execute<T>(executable: @escaping (Token) throws -> Single<T>) -> Single<T>
}

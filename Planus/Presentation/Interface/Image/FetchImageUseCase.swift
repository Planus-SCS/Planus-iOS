//
//  FetchImageUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

protocol FetchImageUseCase {
    func execute(key: String) -> Single<Data>
}

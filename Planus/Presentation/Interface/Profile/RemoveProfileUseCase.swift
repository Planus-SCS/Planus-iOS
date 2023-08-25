//
//  RemoveProfileUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/24.
//

import Foundation
import RxSwift

protocol RemoveProfileUseCase {
    func execute(token: Token) -> Single<Void>
}

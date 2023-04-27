//
//  CreateTodoCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

protocol CreateCategoryUseCase {
    func execute(token: Token, category: Category) -> Single<Int>
}

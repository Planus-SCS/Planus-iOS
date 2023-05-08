//
//  CreateTodoCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

protocol CreateCategoryUseCase {
    var didCreateCategory: PublishSubject<Category> { get }
    func execute(token: Token, category: Category) -> Single<Int>
}

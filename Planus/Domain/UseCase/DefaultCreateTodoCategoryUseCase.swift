//
//  DefaultCreateTodoCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

class DefaultCreateTodoCategoryUseCase {
    let categoryRepository: CategoryRepository
    
    init(
        categoryRepository: CategoryRepository
    ) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, category: TodoCategory) -> Single<Int> {
        return categoryRepository.create(
            token: token.accessToken,
            category: category.toDTO()
        )
        .map {
            $0.data.id
        }
    }
}

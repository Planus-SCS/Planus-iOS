//
//  DefaultUpdateTodoCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

class DefaultUpdateTodoCategoryUseCase {
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


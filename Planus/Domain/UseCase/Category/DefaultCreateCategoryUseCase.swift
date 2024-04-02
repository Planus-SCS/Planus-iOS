//
//  DefaultCreateCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

class DefaultCreateCategoryUseCase: CreateCategoryUseCase {

    let categoryRepository: CategoryRepository
    
    var didCreateCategory = PublishSubject<Category>()
    
    init(
        categoryRepository: CategoryRepository
    ) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, category: Category) -> Single<Int> {
        return categoryRepository.create(
            token: token.accessToken,
            category: category.toDTO()
        )
        .map { [weak self] dto in
            var categoryWithId = category
            categoryWithId.id = dto.data.id
            self?.didCreateCategory.onNext(categoryWithId)
            return dto.data.id
        }
    }
}

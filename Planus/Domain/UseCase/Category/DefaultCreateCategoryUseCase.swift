//
//  DefaultCreateCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

final class DefaultCreateCategoryUseCase: CreateCategoryUseCase {

    let categoryRepository: CategoryRepository
    let didCreateCategory = PublishSubject<Category>()
    
    init(
        categoryRepository: CategoryRepository
    ) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, category: Category) -> Single<Category> {
        return categoryRepository.create(
            token: token.accessToken,
            category: category.toDTO()
        )
        .map { dto in
            var categoryWithId = category
            categoryWithId.id = dto.data.id
            return categoryWithId
        }
        .do(onSuccess: { [weak self] newCategory in
            self?.didCreateCategory.onNext(newCategory)
        })
    }
}

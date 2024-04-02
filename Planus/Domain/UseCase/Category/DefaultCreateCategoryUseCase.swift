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
    
    func execute(token: Token, category: Category) -> Single<Int> {
        return categoryRepository.create(
            token: token.accessToken,
            category: category.toDTO()
        )
        .map { $0.data.id }
        .do(onSuccess: { [weak self] id in
            var categoryWithId = category
            categoryWithId.id = id
            self?.didCreateCategory.onNext(categoryWithId)
        })
    }
}

//
//  DefaultUpdateTodoCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

final class DefaultUpdateCategoryUseCase: UpdateCategoryUseCase {

    let categoryRepository: CategoryRepository
    let didUpdateCategory = PublishSubject<Category>()
    
    init(
        categoryRepository: CategoryRepository
    ) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, id: Int, category: Category) -> Single<Category> {
        return categoryRepository.update(
            token: token.accessToken,
            id: id,
            category: category.toDTO()
        )
        .map { dto in
            var newCategory = category
            newCategory.id = id
            return newCategory
        }
        .do(onSuccess: { [weak self] newCategory in
            self?.didUpdateCategory.onNext(newCategory)
        })
    }
}


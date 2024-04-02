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
    
    func execute(token: Token, id: Int, category: Category) -> Single<Int> {
        return categoryRepository.update(
            token: token.accessToken,
            id: id,
            category: category.toDTO()
        )
        .map { $0.data.id }
        .do(onSuccess: { [weak self] _ in
            self?.didUpdateCategory.onNext(category)
        })
    }
}


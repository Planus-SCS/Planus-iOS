//
//  DefaultUpdateTodoCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

class DefaultUpdateCategoryUseCase: UpdateCategoryUseCase {
    let categoryRepository: CategoryRepository
    
    var didUpdateCategory = PublishSubject<Category>()
    
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
            self?.didUpdateCategory.onNext(category)
            return dto.data.id
        }
    }
}


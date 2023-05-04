//
//  DefaultUpdateTodoCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

class DefaultUpdateCategoryUseCase: UpdateCategoryUseCase {
    static let shared: DefaultUpdateCategoryUseCase = .init(categoryRepository: DefaultCategoryRepository(apiProvider: NetworkManager()))
    let categoryRepository: CategoryRepository
    
    var didUpdateCategory = PublishSubject<Category>()
    
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
        .map { [weak self] dto in
            self?.didUpdateCategory.onNext(category)
            return dto.data.id
        }
    }
}


//
//  DefaultFetchGroupCategorysUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

class DefaultFetchGroupCategorysUseCase: FetchAllGroupCategoryListUseCase {
    let categoryRepository: CategoryRepository
    
    init(categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token) -> Single<[Category]> {
        return categoryRepository
            .fetchAllGroupCategory(token: token.accessToken)
            .map { $0.data.map { $0.toDomain() } }
    }
}


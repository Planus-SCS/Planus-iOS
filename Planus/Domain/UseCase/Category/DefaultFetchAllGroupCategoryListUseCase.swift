//
//  DefaultFetchGroupUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/30.
//

import Foundation
import RxSwift

class DefaultFetchAllGroupCategoryListUseCase: FetchAllGroupCategoryListUseCase {
    let categoryRepository: GroupCategoryRepository
    
    init(categoryRepository: GroupCategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token) -> Single<[Category]> {
        return categoryRepository
            .fetchAllGroupCategory(token: token.accessToken)
            .map { $0.data.map { $0.toDomain() } }
    }
}

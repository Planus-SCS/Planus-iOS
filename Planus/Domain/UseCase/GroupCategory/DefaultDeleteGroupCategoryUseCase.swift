//
//  DefaultDeleteGroupCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

final class DefaultDeleteGroupCategoryUseCase: DeleteGroupCategoryUseCase {
    private let categoryRepository: GroupCategoryRepository
        
    init(categoryRepository: GroupCategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, groupId: Int, categoryId: Int) -> Single<Int> {
        let accessToken = token.accessToken
        return categoryRepository
            .delete(token: accessToken, groupId: groupId, categoryId: categoryId)
            .map { dto in
                return dto.data.id
            }
    }
}

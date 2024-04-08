//
//  DefaultCreateGroupCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

final class DefaultCreateGroupCategoryUseCase: CreateGroupCategoryUseCase {
    let categoryRepository: GroupCategoryRepository
        
    init(
        categoryRepository: GroupCategoryRepository
    ) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, groupId: Int, category: Category) -> Single<Category> {
        return categoryRepository.create(
            token: token.accessToken,
            groupId: groupId,
            category: category.toDTO()
        )
        .map { dto in
            var newValue = category
            newValue.id = dto.data.id
            return newValue
        }
    }
}

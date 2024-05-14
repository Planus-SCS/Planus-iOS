//
//  DefaultUpdateGroupCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

final class DefaultUpdateGroupCategoryUseCase: UpdateGroupCategoryUseCase {

    private let categoryRepository: GroupCategoryRepository
    private let didUpdateCategoryWithGroupId = PublishSubject<(groupId: Int, category: Category)>()
    
    init(
        categoryRepository: GroupCategoryRepository
    ) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, groupId: Int, categoryId: Int, category: Category) -> Single<Category> {
        return categoryRepository.update(
            token: token.accessToken,
            groupId: groupId,
            categoryId: categoryId,
            category: category.toDTO()
        )
        .do(onSuccess: { [weak self] _ in
            self?.didUpdateCategoryWithGroupId.onNext((groupId: groupId, category: category))
        })
        .map { dto in
            var newValue = category
            newValue.id = categoryId
            return newValue
        }
    }
}



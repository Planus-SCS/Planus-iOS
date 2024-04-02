//
//  DefaultUpdateGroupCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

class DefaultUpdateGroupCategoryUseCase: UpdateGroupCategoryUseCase {

    let categoryRepository: GroupCategoryRepository
    
    var didUpdateCategoryWithGroupId = PublishSubject<(groupId: Int, category: Category)>()
    
    init(
        categoryRepository: GroupCategoryRepository
    ) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, groupId: Int, categoryId: Int, category: Category) -> Single<Int> {
        return categoryRepository.update(
            token: token.accessToken,
            groupId: groupId,
            categoryId: categoryId,
            category: category.toDTO()
        )
        .map { [weak self] dto in
            self?.didUpdateCategoryWithGroupId.onNext((groupId: groupId, category: category))
            return dto.data.id
        }
    }
}



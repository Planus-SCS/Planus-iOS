//
//  DefaultDeleteGroupCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

class DefaultDeleteGroupCategoryUseCase: DeleteGroupCategoryUseCase {
    let categoryRepository: GroupCategoryRepository
    
    var didDeleteCategory = PublishSubject<Int>()
    
    init(categoryRepository: GroupCategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, groupId: Int, categoryId: Int) -> Single<Int> {
        let accessToken = token.accessToken
        return categoryRepository
            .delete(token: accessToken, groupId: groupId, categoryId: categoryId)
            .map { [weak self] dto in
                return dto.data.id
            }
    }
}

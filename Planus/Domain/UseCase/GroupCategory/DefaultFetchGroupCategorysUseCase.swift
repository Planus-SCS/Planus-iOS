//
//  DefaultFetchGroupCategorysUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

final class DefaultFetchGroupCategorysUseCase: FetchGroupCategorysUseCase {
    private let categoryRepository: GroupCategoryRepository
    
    init(categoryRepository: GroupCategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, groupId: Int) -> Single<[Category]> {
        let accessToken = token.accessToken
        return categoryRepository
            .fetchGroupCategory(token: accessToken, groupId: groupId)
            .map {
                $0.data.map {
                    $0.toDomain()
                }
            }
    }
}


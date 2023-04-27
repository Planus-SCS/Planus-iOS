//
//  DefaultReadTodoCategoryListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

class DefaultReadTodoCategoryListUseCase {
    let categoryRepository: CategoryRepository
    
    init(categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token) -> Single<[TodoCategory]> {
        let accessToken = token.accessToken
        return categoryRepository
            .read(token: accessToken)
            .map {
                $0.data.map {
                    $0.toDomain()
                }
            }
    }
}

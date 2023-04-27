//
//  DefaultDeleteTodoCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

class DefaultDeleteTodoCategoryUseCase {
    let categoryRepository: CategoryRepository
    
    init(categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, id: Int) -> Single<Void> {
        let accessToken = token.accessToken
        return categoryRepository
            .delete(token: accessToken, id: id)
            .map { return () }
    }
}

//
//  DefaultDeleteTodoCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

final class DefaultDeleteCategoryUseCase: DeleteCategoryUseCase {

    private let categoryRepository: CategoryRepository
    
    var didDeleteCategory = PublishSubject<Int>()
    
    init(categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(token: Token, id: Int) -> Single<Void> {
        let accessToken = token.accessToken
        return categoryRepository
            .delete(token: accessToken, id: id)
            .map { _ in return }
            .do(onSuccess: { [weak self] _ in
                self?.didDeleteCategory.onNext(id)
            })
    }
}

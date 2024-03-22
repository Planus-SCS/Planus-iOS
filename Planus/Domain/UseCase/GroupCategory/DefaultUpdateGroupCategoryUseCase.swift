//
//  DefaultUpdateGroupCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

class DefaultUpdateGroupCategoryUseCase: UpdateGroupCategoryUseCase { //이건 받아서 다시 fetch 해야함!
    static let shared: DefaultUpdateGroupCategoryUseCase = .init(categoryRepository: DefaultGroupCategoryRepository(apiProvider: NetworkManager()))
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



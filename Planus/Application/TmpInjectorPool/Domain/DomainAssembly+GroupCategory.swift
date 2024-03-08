//
//  DomainAssembly+GroupCategory.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {
    
    func assembleGroupCategory(container: Container) {
        container.register(FetchAllGroupCategoryListUseCase.self) { r in
            let groupCateogoryRepository = r.resolve(GroupCategoryRepository.self)!
            return DefaultFetchAllGroupCategoryListUseCase(categoryRepository: groupCateogoryRepository)
        }
        
        container.register(FetchGroupCategorysUseCase.self) { r in
            let groupCateogoryRepository = r.resolve(GroupCategoryRepository.self)!
            return DefaultFetchGroupCategorysUseCase(categoryRepository: groupCateogoryRepository)
        }
        
        container.register(CreateGroupCategoryUseCase.self) { r in
            let groupCateogoryRepository = r.resolve(GroupCategoryRepository.self)!
            return DefaultCreateGroupCategoryUseCase(categoryRepository: groupCateogoryRepository)
        }

        container.register(UpdateGroupCategoryUseCase.self) { r in
            let groupCateogoryRepository = r.resolve(GroupCategoryRepository.self)!
            return DefaultUpdateGroupCategoryUseCase(categoryRepository: groupCateogoryRepository)
        }.inObjectScope(.container)
        
        container.register(DeleteGroupCategoryUseCase.self) { r in
            let groupCateogoryRepository = r.resolve(GroupCategoryRepository.self)!
            return DefaultDeleteGroupCategoryUseCase(categoryRepository: groupCateogoryRepository)
        }
    }
    
}

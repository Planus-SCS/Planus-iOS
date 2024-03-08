//
//  DomainAssembly+Category.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {
    
    func assembleCategory(container: Container) {
        container.register(CreateCategoryUseCase.self) { r in
            let categoryRepository = r.resolve(CategoryRepository.self)!
            return DefaultCreateCategoryUseCase(categoryRepository: categoryRepository)
        }.inObjectScope(.container)
        
        container.register(ReadCategoryListUseCase.self) { r in
            let categoryRepository = r.resolve(CategoryRepository.self)!
            return DefaultReadCategoryListUseCase(categoryRepository: categoryRepository)
        }
        
        container.register(UpdateCategoryUseCase.self) { r in
            let categoryRepository = r.resolve(CategoryRepository.self)!
            return DefaultUpdateCategoryUseCase(categoryRepository: categoryRepository)
        }.inObjectScope(.container)
        
        container.register(DeleteCategoryUseCase.self) { r in
            let categoryRepository = r.resolve(CategoryRepository.self)!
            return DefaultDeleteCategoryUseCase(categoryRepository: categoryRepository)
        }.inObjectScope(.container)
    }
    
}

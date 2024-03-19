//
//  DomainAssembly+Todo.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {
    
    func assembleTodo(container: Container) {
        container.register(ReadTodoListUseCase.self) { r in
            let todoRepository = r.resolve(TodoRepository.self)!
            return DefaultReadTodoListUseCase(todoRepository: todoRepository)
        }
        
        container.register(CreateTodoUseCase.self) { r in
            let todoRepository = r.resolve(TodoRepository.self)!
            return DefaultCreateTodoUseCase(todoRepository: todoRepository)
        }.inObjectScope(.container)
        
        container.register(UpdateTodoUseCase.self) { r in
            let todoRepository = r.resolve(TodoRepository.self)!
            return DefaultUpdateTodoUseCase(todoRepository: todoRepository)
        }.inObjectScope(.container)
        
        container.register(DeleteTodoUseCase.self) { r in
            let todoRepository = r.resolve(TodoRepository.self)!
            return DefaultDeleteTodoUseCase(todoRepository: todoRepository)
        }.inObjectScope(.container)
        
        container.register(TodoCompleteUseCase.self) { r in
            let todoRepository = r.resolve(TodoRepository.self)!
            return DefaultTodoCompleteUseCase(todoRepository: todoRepository)
        }.inObjectScope(.container)
        
    }
    
}

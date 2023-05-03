//
//  DefaultCreateTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

class DefaultCreateTodoUseCase: CreateTodoUseCase {
    static let shared: DefaultCreateTodoUseCase = .init(todoRepository: TestTodoDetailRepository(apiProvider: NetworkManager()))
    let todoRepository: TodoRepository
        
    var didCreateTodo = PublishSubject<Todo>()
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(token: Token, todo: Todo) -> Single<Int> {
        return todoRepository
            .createTodo(token: token.accessToken, todo: todo.toDTO())
            .map { [weak self] id in
                var todoWithId = todo
                todoWithId.id = id
                self?.didCreateTodo.onNext(todoWithId)
                return id
            }
    }
}

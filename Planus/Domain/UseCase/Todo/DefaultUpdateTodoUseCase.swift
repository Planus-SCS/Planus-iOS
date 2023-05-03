//
//  DefaultUpdateTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

class DefaultUpdateTodoUseCase: UpdateTodoUseCase {
    let todoRepository: TodoRepository
        
    var didUpdateTodo = PublishSubject<Todo>()
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(token: Token, todo: Todo) -> Single<Void> {
        return todoRepository
            .updateTodo(token: token.accessToken, id: todo.id ?? Int(), todo: todo.toDTO())
            .map { [weak self] _ in
                self?.didUpdateTodo.onNext(todo)
                return ()
            }
    }
}

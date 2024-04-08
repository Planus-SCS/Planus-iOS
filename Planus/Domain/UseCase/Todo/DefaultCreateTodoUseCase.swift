//
//  DefaultCreateTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

final class DefaultCreateTodoUseCase: CreateTodoUseCase {

    let todoRepository: TodoRepository
    let didCreateTodo = PublishSubject<Todo>()
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(token: Token, todo: Todo) -> Single<Int> {
        return todoRepository
            .createTodo(token: token.accessToken, todo: todo.toDTO())
            .map { $0.data.todoId }
            .do(onSuccess: { [weak self] id in
                var todoWithId = todo
                todoWithId.id = id
                todoWithId.isCompleted = false
                self?.didCreateTodo.onNext(todoWithId)
            })
    }
}

//
//  DefaultDeleteTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

final class DefaultDeleteTodoUseCase: DeleteTodoUseCase {

    private let todoRepository: TodoRepository

    var didDeleteTodo = PublishSubject<Todo>()
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(token: Token, todo: Todo) -> Single<Void> {
        return todoRepository
            .deleteTodo(token: token.accessToken, id: todo.id ?? Int())
            .do(onSuccess: { [weak self] in
                self?.didDeleteTodo.onNext(todo)
            })
    }
}

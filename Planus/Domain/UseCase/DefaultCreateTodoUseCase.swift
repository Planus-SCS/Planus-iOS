//
//  DefaultCreateTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

class DefaultCreateTodoUseCase: CreateTodoUseCase {
    let todoRepository: TodoRepository
    
    var didCreateTodo = PublishSubject<Todo>()
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(todo: Todo) -> Single<Void> {
        return todoRepository
            .createTodo(todo: todo)
            .map { [weak self] in
                self?.didCreateTodo.onNext(todo)
                return $0
            }
    }
}

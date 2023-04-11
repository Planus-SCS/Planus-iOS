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
    
    func execute(todo: Todo) -> Single<Void> {
        return todoRepository
            .updateTodo(todo: todo)
            .map { [weak self] in
                self?.didUpdateTodo.onNext(todo)
                return $0
            }
    }
}

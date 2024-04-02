//
//  DefaultDeleteTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

class DefaultDeleteTodoUseCase: DeleteTodoUseCase {

    let todoRepository: TodoRepository

    var didDeleteTodo = PublishSubject<Todo>()
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(token: Token, todo: Todo) -> Single<Void> { //id만 담아서 보내면 되나? 아니! 보낼때는 id만 담되, 제거할땐 투두 자체를 뿌리자
        return todoRepository
            .deleteTodo(token: token.accessToken, id: todo.id ?? Int())
            .map { [weak self] in
                self?.didDeleteTodo.onNext(todo)
                return $0
            }
    }
}

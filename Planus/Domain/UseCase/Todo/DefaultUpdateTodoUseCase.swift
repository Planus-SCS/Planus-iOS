//
//  DefaultUpdateTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

class DefaultUpdateTodoUseCase: UpdateTodoUseCase {
    static let shared: DefaultUpdateTodoUseCase = .init(todoRepository: TestTodoDetailRepository(apiProvider: NetworkManager()))

    let todoRepository: TodoRepository
        
    var didUpdateTodo = PublishSubject<TodoUpdateComparator>()
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(token: Token, todoUpdate: TodoUpdateComparator) -> Single<Void> {
        return todoRepository
            .updateTodo(token: token.accessToken, id: todoUpdate.after.id ?? Int(), todo: todoUpdate.after.toDTO())
            .map { [weak self] _ in
                self?.didUpdateTodo.onNext(todoUpdate)
                return ()
            }
    }
}

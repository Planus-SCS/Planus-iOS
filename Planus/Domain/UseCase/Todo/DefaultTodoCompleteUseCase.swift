//
//  DefaultTodoCompleteUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/31.
//

import Foundation
import RxSwift

final class DefaultTodoCompleteUseCase: TodoCompleteUseCase {

    private let todoRepository: TodoRepository
    let didCompleteTodo = PublishSubject<Todo>()
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(token: Token, todo: Todo) -> Single<Void> {
        let type: TodoCompletionType = todo.isGroupTodo ? .group(todo.groupId ?? -1) : .member
        switch type {
        case .member:
            return todoRepository
                .memberCompletion(token: token.accessToken, todoId: todo.id ?? Int())
                .map { _ in return }
                .do(onSuccess: { [weak self] _ in
                    self?.didCompleteTodo.onNext(todo)
                })
        case .group(let groupId):
            return todoRepository
                .groupCompletion(token: token.accessToken, groupId: groupId, todoId: todo.id ?? Int())
                .map { _ in return }
                .do(onSuccess: { [weak self] _ in
                    self?.didCompleteTodo.onNext(todo)
                })
        }
    }
}

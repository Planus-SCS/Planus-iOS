//
//  DefaultTodoCompleteUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/31.
//

import Foundation
import RxSwift

class DefaultTodoCompleteUseCase: TodoCompleteUseCase {
    let todoRepository: TodoRepository
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(token: Token, todoId: Int, type: TodoCompletionType) -> Single<Void> {
        switch type {
        case .member:
            return todoRepository
                .memberCompletion(token: token.accessToken, todoId: todoId)
                .map { _ in }
        case .group(let groupId):
            return todoRepository
                .groupCompletion(token: token.accessToken, groupId: groupId, todoId: todoId)
                .map { _ in }
        }
    }
}

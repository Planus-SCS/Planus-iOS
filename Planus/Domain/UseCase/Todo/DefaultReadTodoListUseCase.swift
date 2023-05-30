//
//  DefaultFetchTodoListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

class DefaultReadTodoListUseCase: ReadTodoListUseCase {
    
    let todoRepository: TodoRepository
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(token: Token, from: Date, to: Date) -> Single<[Date: [Todo]]> {
        return todoRepository
            .readTodo(token: token.accessToken, from: from, to: to)
            .map { return $0.data }
            .map { list in
                var dict = [Date: [Todo]]()
                list.groupTodos.forEach { entity in
                    let todo = entity.toDomain(isGroup: true)
                    if dict[todo.startDate] == nil {
                        dict[todo.startDate] = []
                    }
                    dict[todo.startDate]?.append(todo)
                }
                list.memberTodos.forEach { entity in
                    let todo = entity.toDomain(isGroup: false)
                    if dict[todo.startDate] == nil {
                        dict[todo.startDate] = []
                    }
                    dict[todo.startDate]?.append(todo)
                }

                return dict
            }
    }
}

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
    
    func execute(from: Date, to: Date) -> Single<[Date: [Todo]]> {
        return todoRepository
            .readTodo(from: from, to: to)
            .map { list in
                var dict = [Date: [Todo]]()
                list.forEach { todo in
                    if dict[todo.startDate] == nil {
                        dict[todo.startDate] = []
                    }
                    dict[todo.startDate]?.append(todo)
                }
                return dict
            }
    }
}

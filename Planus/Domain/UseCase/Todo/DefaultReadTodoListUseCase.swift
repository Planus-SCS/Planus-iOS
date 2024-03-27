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

                    var dateItr = todo.startDate
                    while dateItr <= todo.endDate {
                        if dict[dateItr] == nil {
                            dict[dateItr] = []
                        }
                        dict[dateItr]?.append(todo)
                        guard let next = Calendar.current.date(
                            byAdding: DateComponents(day: 1),
                            to: dateItr) else { break }
                        dateItr = next
                    }
                }
                list.memberTodos.forEach { entity in
                    let todo = entity.toDomain(isGroup: false)
                    
                    var dateItr = todo.startDate
                    while dateItr <= todo.endDate {
                        if dict[dateItr] == nil {
                            dict[dateItr] = []
                        }
                        dict[dateItr]?.append(todo)
                        guard let next = Calendar.current.date(
                            byAdding: DateComponents(day: 1),
                            to: dateItr) else { break }
                        dateItr = next
                    }
                }

                return dict
            }
    }
}

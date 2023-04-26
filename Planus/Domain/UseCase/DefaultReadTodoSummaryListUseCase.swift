//
//  DefaultFetchTodoListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

class DefaultReadTodoSummaryListUseCase: ReadTodoSummaryListUseCase {
    
    let todoRepository: TodoDetailRepository
    
    init(todoRepository: TodoDetailRepository) {
        self.todoRepository = todoRepository
    }
    
    func execute(from: Date, to: Date) -> Single<[Date: [TodoSummary]]> { //정렬된 상태로 받는다는 가정 하에 이런식으로 day마다 리스트를 나눠줌
        return todoRepository
            .readTodo(from: from, to: to)
            .map { list in
                var dict = [Date: [TodoSummary]]()
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

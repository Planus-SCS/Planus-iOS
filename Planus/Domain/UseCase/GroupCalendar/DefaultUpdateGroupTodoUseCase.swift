//
//  DefaultUpdateGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

final class DefaultUpdateGroupTodoUseCase: UpdateGroupTodoUseCase {
    
    private let groupCalendarRepository: GroupCalendarRepository
    let didUpdateGroupTodo = PublishSubject<Todo>()
    
    init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, todoId: Int, todo: Todo) -> Single<Int> {
        groupCalendarRepository
            .updateTodo(token: token.accessToken, groupId: groupId, todoId: todoId, todo: todo.toDTO())
            .do(onSuccess: { [weak self] _ in
                self?.didUpdateGroupTodo.onNext(todo)
            })
    }
}

//
//  DefaultCreateGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

final class DefaultCreateGroupTodoUseCase: CreateGroupTodoUseCase {
    
    let groupCalendarRepository: GroupCalendarRepository
    let didCreateGroupTodo = PublishSubject<Todo>()
    
    init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, todo: Todo) -> Single<Int> {
        groupCalendarRepository
            .createTodo(token: token.accessToken, groupId: groupId, todo: todo.toDTO())
            .do(onSuccess: { [weak self] _ in
                self?.didCreateGroupTodo.onNext(todo)
            })
    }
}

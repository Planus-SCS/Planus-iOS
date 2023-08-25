//
//  DefaultUpdateGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

class DefaultUpdateGroupTodoUseCase: UpdateGroupTodoUseCase {
    static let shared = DefaultUpdateGroupTodoUseCase(groupCalendarRepository: DefaultGroupCalendarRepository(apiProvider: NetworkManager()))
    
    let groupCalendarRepository: GroupCalendarRepository
    var didUpdateGroupTodo = PublishSubject<Todo>()
    
    private init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, todoId: Int, todo: Todo) -> Single<Int> {
        groupCalendarRepository
            .updateTodo(token: token.accessToken, groupId: groupId, todoId: todoId, todo: todo.toDTO())
            .map { [weak self] in
                self?.didUpdateGroupTodo.onNext(todo)
                return $0
            }
    }
}

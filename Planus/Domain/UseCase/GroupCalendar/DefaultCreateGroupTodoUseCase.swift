//
//  DefaultCreateGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

class DefaultCreateGroupTodoUseCase: CreateGroupTodoUseCase {
    static let shared = DefaultCreateGroupTodoUseCase(groupCalendarRepository: DefaultGroupCalendarRepository(apiProvider: NetworkManager()))
    
    let groupCalendarRepository: GroupCalendarRepository
    
    var didCreateGroupTodo = PublishSubject<Todo>()
    
    init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, todo: Todo) -> Single<Int> {
        groupCalendarRepository
            .createTodo(token: token.accessToken, groupId: groupId, todo: todo.toDTO())
            .map { [weak self] in
                print("emit!")
                self?.didCreateGroupTodo.onNext(todo)
                return $0
            }
    }
}

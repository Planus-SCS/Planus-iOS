//
//  DefaultCreateGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

class DefaultCreateGroupTodoUseCase: CreateGroupTodoUseCase {
    let groupCalendarRepository: GroupCalendarRepository
    
    init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, todo: Todo) -> Single<Int> {
        groupCalendarRepository
            .createTodo(token: token.accessToken, groupId: groupId, todo: todo.toDTO())
    }
}

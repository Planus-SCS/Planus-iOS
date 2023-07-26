//
//  DefaultDeleteGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

class DefaultDeleteGroupTodoUseCase: DeleteGroupTodoUseCase {
    let groupCalendarRepository: GroupCalendarRepository
    
    init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, todoId: Int) -> Single<Void> {
        groupCalendarRepository
            .deleteTodo(token: token.accessToken, groupId: groupId, todoId: todoId)
    }
}

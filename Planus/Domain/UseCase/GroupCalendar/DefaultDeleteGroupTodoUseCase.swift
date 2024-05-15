//
//  DefaultDeleteGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

final class DefaultDeleteGroupTodoUseCase: DeleteGroupTodoUseCase {

    private let groupCalendarRepository: GroupCalendarRepository
    let didDeleteGroupTodoWithIds = PublishSubject<(groupId: Int, todoId: Int)>()
    
    init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, todoId: Int) -> Single<Void> {
        groupCalendarRepository
            .deleteTodo(token: token.accessToken, groupId: groupId, todoId: todoId)
            .do(onSuccess: { [weak self] in
                self?.didDeleteGroupTodoWithIds.onNext((groupId: groupId, todoId: todoId))
            })
    }
}

//
//  DefaultDeleteGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

class DefaultDeleteGroupTodoUseCase: DeleteGroupTodoUseCase {
    static let shared = DefaultDeleteGroupTodoUseCase(groupCalendarRepository: DefaultGroupCalendarRepository(apiProvider: NetworkManager()))
    let groupCalendarRepository: GroupCalendarRepository
    
    var didDeleteGroupTodoWithIds = PublishSubject<(groupId: Int, todoId: Int)>()
    
    init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, todoId: Int) -> Single<Void> {
        groupCalendarRepository
            .deleteTodo(token: token.accessToken, groupId: groupId, todoId: todoId)
            .map { [weak self] in
                self?.didDeleteGroupTodoWithIds.onNext((groupId: groupId, todoId: todoId))
            }
    }
}

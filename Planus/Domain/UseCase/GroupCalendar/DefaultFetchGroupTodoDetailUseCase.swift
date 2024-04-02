//
//  DefaultFetchGroupTodoDetailUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

final class DefaultFetchGroupTodoDetailUseCase: FetchGroupTodoDetailUseCase {
    let groupCalendarRepository: GroupCalendarRepository
    
    init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, todoId: Int) -> Single<SocialTodoDetail> {
        groupCalendarRepository
            .fetchTodoDetail(token: token.accessToken, groupId: groupId, todoId: todoId)
            .map {
                $0.data.toDomain()
            }
    }
}

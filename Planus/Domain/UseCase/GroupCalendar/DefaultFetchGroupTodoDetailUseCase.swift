//
//  DefaultFetchGroupTodoDetailUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

class DefaultFetchGroupTodoDetailUseCase: FetchGroupTodoDetailUseCase {
    let groupCalendarRepositry: GroupCalendarRepository
    
    init(groupCalendarRepositry: GroupCalendarRepository) {
        self.groupCalendarRepositry = groupCalendarRepositry
    }
    
    func execute(token: Token, groupId: Int, todoId: Int) -> Single<SocialTodoDetail> {
        groupCalendarRepositry
            .fetchTodoDetail(token: token.accessToken, groupId: groupId, todoId: todoId)
            .map {
                $0.data.toDomain()
            }
    }
}

//
//  DefaultFetchGroupMemberTodoDetailUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

final class DefaultFetchGroupMemberTodoDetailUseCase: FetchGroupMemberTodoDetailUseCase {
    let groupMemberCalendarRepository: GroupMemberCalendarRepository
    
    init(groupMemberCalendarRepository: GroupMemberCalendarRepository) {
        self.groupMemberCalendarRepository = groupMemberCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, memberId: Int, todoId: Int) -> Single<SocialTodoDetail> {
        return groupMemberCalendarRepository
            .fetchMemberTodoDetail(
                token: token.accessToken,
                groupId: groupId,
                memberId: memberId,
                todoId: todoId
            )
            .map {
                $0.data.toDomain()
            }
    }
}

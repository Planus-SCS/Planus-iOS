//
//  DefaultFetchMemberTodoListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/16.
//

import Foundation
import RxSwift

class DefaultFetchMemberTodoListUseCase: FetchMemberTodoListUseCase {
    let memberCalendarRepository: MemberCalendarRepository
    
    init(memberCalendarRepository: MemberCalendarRepository) {
        self.memberCalendarRepository = memberCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, memberId: Int, from: Date, to: Date) -> Single<[Date: [Todo]]> {
        return memberCalendarRepository
            .fetchMemberTodoList(
                token: token.accessToken,
                groupId: groupId,
                memberId: memberId,
                from: from,
                to: to
            )
            .map { return $0.data }
            .map { list in
                var dict = [Date: [Todo]]()
                list.forEach { dto in
                    let todo = dto.toDomain()
                    if dict[todo.startDate] == nil {
                        dict[todo.startDate] = []
                    }
                    dict[todo.startDate]?.append(todo)
                }
                return dict
            }
    }
}

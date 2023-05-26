//
//  DefaultFetchMemberTodoListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/16.
//

import Foundation
import RxSwift

class DefaultFetchMemberCalendarUseCase: FetchMemberCalendarUseCase {
    let memberCalendarRepository: MemberCalendarRepository
    
    init(memberCalendarRepository: MemberCalendarRepository) {
        self.memberCalendarRepository = memberCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, memberId: Int, from: Date, to: Date) -> Single<[SocialTodoSummary]> {
        return memberCalendarRepository
            .fetchMemberCalendar(
                token: token.accessToken,
                groupId: groupId,
                memberId: memberId,
                from: from,
                to: to
            )
            .map {
                $0.data.map {
                    $0.toDomain()
                }
            }
    }
}

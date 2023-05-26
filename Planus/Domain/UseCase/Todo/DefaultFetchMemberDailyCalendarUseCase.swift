//
//  DefaultFetchMemberDailyCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

class DefaultFetchMemberDailyCalendarUseCase: FetchMemberDailyCalendarUseCase {
    let memberCalendarRepository: MemberCalendarRepository
    
    init(memberCalendarRepository: MemberCalendarRepository) {
        self.memberCalendarRepository = memberCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, memberId: Int, date: Date) -> Single<[[SocialTodoDaily]]> {
        memberCalendarRepository.fetchMemberDailyCalendar(
            token: token.accessToken,
            groupId: groupId,
            memberId: memberId,
            date: date
        )
        .map {
            var tmp = [[SocialTodoDaily]]()
            tmp.append($0.data.dailySchedules.map { $0.toDomain() })
            tmp.append($0.data.dailyTodos.map { $0.toDomain() })
            return tmp
        }
    }
}

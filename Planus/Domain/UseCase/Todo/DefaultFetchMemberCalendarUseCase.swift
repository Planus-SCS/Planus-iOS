//
//  DefaultFetchMemberCalendarUseCase.swift
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
    
    func execute(token: Token, groupId: Int, memberId: Int, from: Date, to: Date) -> Single<[Date: [SocialTodoSummary]]> {
        return memberCalendarRepository
            .fetchMemberCalendar(
                token: token.accessToken,
                groupId: groupId,
                memberId: memberId,
                from: from,
                to: to
            )
            .map { $0.data.map { $0.toDomain() } }
            .map { list in
                var dict = [Date: [SocialTodoSummary]]()
                list.forEach { todo in
                    
                    var dateItr = todo.startDate
                    while dateItr <= todo.endDate {
                        if dict[dateItr] == nil {
                            dict[dateItr] = []
                        }
                        dict[dateItr]?.append(todo)
                        guard let next = Calendar.current.date(
                            byAdding: DateComponents(day: 1),
                            to: dateItr) else { break }
                        dateItr = next
                    }
                }
                return dict
            }
    }
}

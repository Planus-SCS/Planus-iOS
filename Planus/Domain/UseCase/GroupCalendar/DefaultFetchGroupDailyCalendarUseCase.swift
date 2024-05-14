//
//  DefaultFetchGroupDailyCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

final class DefaultFetchGroupDailyCalendarUseCase: FetchGroupDailyCalendarUseCase {
    private let groupCalendarRepository: GroupCalendarRepository
    
    init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, date: Date) -> Single<[[SocialTodoDaily]]> {
        groupCalendarRepository.fetchDailyCalendar(
            token: token.accessToken,
            groupId: groupId,
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

//
//  DefaultFetchGroupMonthlyCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

final class DefaultFetchGroupMonthlyCalendarUseCase: FetchGroupMonthlyCalendarUseCase {
    private let groupCalendarRepository: GroupCalendarRepository
    
    init(groupCalendarRepository: GroupCalendarRepository) {
        self.groupCalendarRepository = groupCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, from: Date, to: Date) -> Single<[Date: [TodoSummaryViewModel]]> {
        groupCalendarRepository.fetchMonthlyCalendar(
            token: token.accessToken,
            groupId: groupId,
            from: from,
            to: to
        )
        .map { $0.data.map { $0.toDomain() } }
        .map { list in
            var dict = [Date: [TodoSummaryViewModel]]()
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

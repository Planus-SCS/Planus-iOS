//
//  DefaultFetchMyGroupCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

class DefaultFetchMyGroupCalendarUseCase: FetchMyGroupCalendarUseCase {
    let myGroupRepository: MyGroupRepository
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupId: Int, from: Date, to: Date) -> Single<[Date: [SocialTodoSummary]]> {
        myGroupRepository.fetchMyGroupCalendar(
            token: token.accessToken,
            groupId: groupId,
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

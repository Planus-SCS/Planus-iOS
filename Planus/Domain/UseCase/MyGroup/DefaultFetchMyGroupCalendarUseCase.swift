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
    
    func execute(token: Token, groupId: Int, from: Date, to: Date) -> Single<[SocialTodoSummary]> {
        myGroupRepository.fetchMyGroupCalendar(
            token: token.accessToken,
            groupId: groupId,
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

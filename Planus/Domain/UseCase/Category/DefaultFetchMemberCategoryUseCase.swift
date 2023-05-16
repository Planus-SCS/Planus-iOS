//
//  DefaultFetchMemberCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/16.
//

import Foundation
import RxSwift

class DefaultFetchMemberCategoryUseCase: FetchMemberCategoryUseCase {
    let memberCalendarRepository: MemberCalendarRepository
    
    init(memberCalendarRepository: MemberCalendarRepository) {
        self.memberCalendarRepository = memberCalendarRepository
    }
    
    func execute(token: Token, groupId: Int, memberId: Int) -> Single<[Category]> {
        return memberCalendarRepository
            .fetchMemberCategoryList(
                token: token.accessToken,
                groupId: groupId,
                memberId: memberId
            )
            .map { dto in
                dto.data.map { $0.toDomain() }
            }
    }
}

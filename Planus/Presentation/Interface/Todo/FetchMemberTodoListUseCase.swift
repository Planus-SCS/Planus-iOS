//
//  FetchMemberTodoRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/16.
//

import Foundation
import RxSwift

protocol FetchGroupMemberCalendarUseCase {
    func execute(token: Token, groupId: Int, memberId: Int, from: Date, to: Date) -> Single<[Date: [SocialTodoSummary]]>
}

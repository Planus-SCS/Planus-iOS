//
//  FetchMemberDailyCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

protocol FetchMemberDailyCalendarUseCase {
    func execute(token: Token, groupId: Int, memberId: Int, date: Date) -> Single<[[SocialTodoDaily]]>
}

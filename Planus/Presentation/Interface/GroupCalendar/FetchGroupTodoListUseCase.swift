//
//  FetchGroupTodoListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

protocol FetchGroupDailyCalendarUseCase {
    func execute(token: Token, groupId: Int, date: Date) -> Single<[[SocialTodoDaily]]>
}

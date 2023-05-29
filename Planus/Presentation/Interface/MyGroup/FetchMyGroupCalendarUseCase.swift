//
//  FetchMyGroupCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

protocol FetchMyGroupCalendarUseCase {
    func execute(token: Token, groupId: Int, from: Date, to: Date) -> Single<[SocialTodoSummary]>
}

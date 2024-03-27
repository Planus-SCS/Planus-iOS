//
//  FetchGroupMonthlyCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

protocol FetchGroupMonthlyCalendarUseCase {
    func execute(token: Token, groupId: Int, from: Date, to: Date) -> Single<[Date: [TodoSummaryViewModel]]>
}

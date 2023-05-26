//
//  GroupCalendarRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

protocol GroupCalendarRepository {
    func readCalendar(token: String, groupId: Int, from: Date, to: Date) -> Single<ResponseDTO<[SocialTodoSummaryResponseDTO]>>
    func readDailyTodoList(token: String, groupId: Int, date: Date) -> Single<ResponseDTO<SocialTodoDailyListResponseDTO>>
}

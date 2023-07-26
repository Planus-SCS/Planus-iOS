//
//  GroupMemberCalendarRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/16.
//

import Foundation
import RxSwift

protocol GroupMemberCalendarRepository {
    func fetchMemberCalendar(
        token: String,
        groupId: Int,
        memberId: Int,
        from: Date,
        to: Date
    ) -> Single<ResponseDTO<[SocialTodoSummaryResponseDTO]>>
    
    func fetchMemberDailyCalendar(
        token: String,
        groupId: Int,
        memberId: Int,
        date: Date
    ) -> Single<ResponseDTO<SocialTodoDailyListResponseDTO>>
}

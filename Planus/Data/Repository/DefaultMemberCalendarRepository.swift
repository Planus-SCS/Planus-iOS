//
//  DefaultMemberCalendarRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/16.
//

import Foundation
import RxSwift

class DefaultMemberCalendarRepository: MemberCalendarRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func fetchMemberCalendar(
        token: String,
        groupId: Int,
        memberId: Int,
        from: Date,
        to: Date
    ) -> Single<ResponseDTO<[SocialTodoSummaryResponseDTO]>> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        
        let endPoint = APIEndPoint(
            url: URLPool.myGroup+"/\(groupId)/members/\(memberId)/calendar",
            requestType: .get,
            body: nil,
            query: [
                "from": dateFormatter.string(from: from),
                "to": dateFormatter.string(from: to)
            ],
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<[SocialTodoSummaryResponseDTO]>.self
        )
    }
    
    func fetchMemberDailyCalendar(
        token: String,
        groupId: Int,
        memberId: Int,
        date: Date
    ) -> Single<ResponseDTO<SocialTodoDailyListResponseDTO>> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        
        let endPoint = APIEndPoint(
            url: URLPool.myGroup+"/\(groupId)/members/\(memberId)/calendar/daily",
            requestType: .get,
            body: nil,
            query: ["date": dateFormatter.string(from: date)],
            header: ["Authorization": "Bearer \(token)"]
        )
        
        return apiProvider
            .requestCodable(
                endPoint: endPoint,
                type: ResponseDTO<SocialTodoDailyListResponseDTO>.self
            )
    }
}

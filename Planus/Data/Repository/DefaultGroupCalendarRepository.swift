//
//  DefaultGroupCalendarRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

class DefaultGroupCalendarRepository: GroupCalendarRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func readCalendar(token: String, groupId: Int, from: Date, to: Date) -> Single<ResponseDTO<[SocialTodoSummaryResponseDTO]>> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/todos/calendar",
            requestType: .get,
            body: nil,
            query: [
                "from": dateFormatter.string(from: from),
                "to": dateFormatter.string(from: to)
            ],
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<[SocialTodoSummaryResponseDTO]>.self
        )
    }
    
    func readDailyTodoList(token: String, groupId: Int, date: Date) -> Single<ResponseDTO<SocialTodoDailyListResponseDTO>> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/todos/calendar/daily",
            requestType: .get,
            body: nil,
            query: [
                "date": dateFormatter.string(from: date)
            ],
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<SocialTodoDailyListResponseDTO>.self
        )
    }
}

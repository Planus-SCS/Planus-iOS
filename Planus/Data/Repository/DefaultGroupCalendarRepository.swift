//
//  DefaultGroupCalendarRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

final class DefaultGroupCalendarRepository: GroupCalendarRepository {
    
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func fetchMonthlyCalendar(token: String, groupId: Int, from: Date, to: Date) -> Single<ResponseDTO<[SocialTodoSummaryResponseDTO]>> {
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
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<[SocialTodoSummaryResponseDTO]>.self
        )
    }
    
    func fetchDailyCalendar(token: String, groupId: Int, date: Date) -> Single<ResponseDTO<SocialTodoDailyListResponseDTO>> {
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
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<SocialTodoDailyListResponseDTO>.self
        )
    }
    
    func fetchTodoDetail(token: String, groupId: Int, todoId: Int) -> Single<ResponseDTO<SocialTodoDetailResponseDTO>>{
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/todos/\(todoId)",
            requestType: .get,
            body: nil,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<SocialTodoDetailResponseDTO>.self
        )
    }
    
    func createTodo(token: String, groupId: Int, todo: TodoRequestDTO) -> Single<Int> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/todos",
            requestType: .post,
            body: todo,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<TodoResponseDataDTO>.self
        )
        .map {
            $0.data.todoId
        }
    }
    
    func updateTodo(token: String, groupId: Int, todoId: Int, todo: TodoRequestDTO) -> Single<Int> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/todos/\(todoId)",
            requestType: .patch,
            body: todo,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<TodoResponseDataDTO>.self
        )
        .map {
            $0.data.todoId
        }
    }
    
    func deleteTodo(token: String, groupId: Int, todoId: Int) -> Single<Void> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/todos/\(todoId)",
            requestType: .delete,
            body: nil,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<TodoResponseDataDTO>.self
        )
        .map { _ in
            return ()
        }
    }
    
    
}

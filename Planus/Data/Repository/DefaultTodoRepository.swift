//
//  DefaultTodoRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

final class DefaultTodoDetailRepository: TodoRepository {
    
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func createTodo(token: String, todo: TodoRequestDTO) -> Single<ResponseDTO<TodoResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.todo,
            requestType: .post,
            body: todo,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TodoResponseDataDTO>.self
        )
    }
    
    func readTodo(token: String, from: Date, to: Date) -> Single<ResponseDTO<TodoListResponseDTO>> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        
        let endPoint = APIEndPoint(
            url: URLPool.calendar,
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
            type: ResponseDTO<TodoListResponseDTO>.self
        )
    }
    
    func updateTodo(token: String, id: Int, todo: TodoRequestDTO) -> Single<ResponseDTO<TodoResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.todo + "/\(id)",
            requestType: .patch,
            body: todo,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TodoResponseDataDTO>.self
        )
    }
    
    func deleteTodo(token: String, id: Int) -> Single<Void> {
        let endPoint = APIEndPoint(
            url: URLPool.todo + "/\(id)",
            requestType: .delete,
            body: nil,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TodoResponseDataDTO>.self
        )
        .map { _ in
            return ()
        }
    }
    
    func memberCompletion(token: String, todoId: Int) -> Single<ResponseDTO<TodoResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.todo + "/\(todoId)/completion",
            requestType: .patch,
            body: nil,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TodoResponseDataDTO>.self
        )
    }
    
    func groupCompletion(token: String, groupId: Int, todoId: Int) -> Single<ResponseDTO<TodoResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/todos/\(todoId)/completion",
            requestType: .patch,
            body: nil,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: ResponseDTO<TodoResponseDataDTO>.self
        )
    }
}

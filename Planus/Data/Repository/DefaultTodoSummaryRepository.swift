//
//  DefaultTodoSummaryRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

class DefaultTodoSummaryRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func read(token: String, from: Date, to: Date) -> Single<TodoSummaryListResponseDTO> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        
        let endPoint = APIEndPoint(
            url: <#T##String#>,
            requestType: .get,
            body: nil,
            query: [
                "from": dateFormatter.string(from: from),
                "to": dateFormatter.string(from: to)
            ],
            header: ["Authorization": token]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: TodoSummaryListResponseDTO.self
        )
    }
}



//
//  DefaultCategoryRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

class DefaultCategoryRepository: CategoryRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func read(token: String) -> Single<TodoCategoryReadResponseDTO> {
        let endPoint = APIEndPoint(
            url: "localhost:8080/app/categories",
            requestType: .get,
            body: nil,
            query: nil,
            header: ["Authorization": token]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: TodoCategoryReadResponseDTO.self
        )
    }
    
    func create(token: String, category: TodoCategoryCreateRequestDTO) -> Single<TodoCategoryCreateResponseDTO> {
        let endPoint = APIEndPoint(
            url: "localhost:8080/app/categories",
            requestType: .post,
            body: category,
            query: nil,
            header: ["Authorization": token]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: TodoCategoryCreateResponseDTO.self
        )
    }
    
    func update(token: String, id: Int, category: TodoCategoryUpdateRequestDTO) -> Single<TodoCategoryUpdateResponseDTO> {
        let endPoint = APIEndPoint(
            url: "localhost:8080/app/categories" + "/\(id)",
            requestType: .patch,
            body: category,
            query: nil,
            header: ["Authorization": token]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: TodoCategoryUpdateResponseDTO.self
        )
    }
    
    func delete(token: String, id: Int) -> Single<TodoCategoryDeleteResponseDTO> {
        let endPoint = APIEndPoint(
            url: "localhost:8080/app/categories" + "/\(id)",
            requestType: .delete,
            body: nil,
            query: nil,
            header: ["Authorization": token]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: TodoCategoryDeleteResponseDTO.self
        )
    }
}

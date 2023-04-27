//
//  DefaultCategoryRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

class DefaultCategoryRepository: CategoryRepository { //읽어온 다음에 메모리 캐시에 존재할 경우 메모리를 이용하도록 하자..!
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func read(token: String) -> Single<TodoCategoryListResponseDTO> {
        let endPoint = APIEndPoint(
            url: "localhost:8080/app/categories",
            requestType: .get,
            body: nil,
            query: nil,
            header: ["Authorization": token]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: TodoCategoryListResponseDTO.self
        )
    }
    
    func create(token: String, category: TodoCategoryRequestDTO) -> Single<TodoCategoryResponseDTO> {
        let endPoint = APIEndPoint(
            url: "localhost:8080/app/categories",
            requestType: .post,
            body: category,
            query: nil,
            header: ["Authorization": token]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: TodoCategoryResponseDTO.self
        )
    }
    
    func update(token: String, id: Int, category: TodoCategoryRequestDTO) -> Single<TodoCategoryResponseDTO> {
        let endPoint = APIEndPoint(
            url: "localhost:8080/app/categories" + "/\(id)",
            requestType: .patch,
            body: category,
            query: nil,
            header: ["Authorization": token]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: TodoCategoryResponseDTO.self
        )
    }
    
    func delete(token: String, id: Int) -> Single<TodoCategoryResponseDTO> {
        let endPoint = APIEndPoint(
            url: "localhost:8080/app/categories" + "/\(id)",
            requestType: .delete,
            body: nil,
            query: nil,
            header: ["Authorization": token]
        )
        
        return apiProvider.requestCodable(
            endPoint: endPoint,
            type: TodoCategoryResponseDTO.self
        )
    }
}

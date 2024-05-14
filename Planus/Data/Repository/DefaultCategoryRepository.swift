//
//  DefaultCategoryRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

final class DefaultCategoryRepository: CategoryRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func read(token: String) -> Single<ResponseDTO<[CategoryEntityResponseDTO]>> {
        let endPoint = APIEndPoint(
            url: URLPool.categories,
            requestType: .get,
            body: nil,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<[CategoryEntityResponseDTO]>.self
        )
    }
    
    func create(token: String, category: CategoryRequestDTO) -> Single<ResponseDTO<CategoryResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.categories,
            requestType: .post,
            body: category,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<CategoryResponseDataDTO>.self
        )
    }
    
    func update(token: String, id: Int, category: CategoryRequestDTO) -> Single<ResponseDTO<CategoryResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.categories + "/\(id)",
            requestType: .patch,
            body: category,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<CategoryResponseDataDTO>.self
        )
    }
    
    func delete(token: String, id: Int) -> Single<ResponseDTO<CategoryResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.categories + "/\(id)",
            requestType: .delete,
            body: nil,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<CategoryResponseDataDTO>.self
        )
    }
}

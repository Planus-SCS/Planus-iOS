//
//  DefaultGroupCategoryRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

final class DefaultGroupCategoryRepository: GroupCategoryRepository {
    let apiProvider: APIProvider
    
    init(apiProvider: APIProvider) {
        self.apiProvider = apiProvider
    }
    
    func fetchAllGroupCategory(token: String) -> Single<ResponseDTO<[CategoryEntityResponseDTO]>> {
        let endPoint = APIEndPoint(
            url: URLPool.categories + URLPathComponent.groups,
            requestType: .get,
            body: nil,
            query: nil,
            header: [
                "Authorization": "Bearer \(token)"
            ]
        )
        
        return apiProvider.request(
            endPoint: endPoint,
            type: ResponseDTO<[CategoryEntityResponseDTO]>.self
        )
    }
    
    func fetchGroupCategory(token: String, groupId: Int) -> Single<ResponseDTO<[CategoryEntityResponseDTO]>> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/categories",
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
    
    func create(token: String, groupId: Int, category: CategoryRequestDTO) -> Single<ResponseDTO<CategoryResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/categories",
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
    
    func update(token: String, groupId: Int, categoryId: Int, category: CategoryRequestDTO) -> Single<ResponseDTO<CategoryResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/categories/\(categoryId)",
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
    
    func delete(token: String, groupId: Int, categoryId: Int) -> Single<ResponseDTO<CategoryResponseDataDTO>> {
        let endPoint = APIEndPoint(
            url: URLPool.myGroup + "/\(groupId)/categories/\(categoryId)",
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

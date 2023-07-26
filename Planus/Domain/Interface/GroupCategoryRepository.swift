//
//  GroupCategoryRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol GroupCategoryRepository {
    func fetchAllGroupCategory(token: String) -> Single<ResponseDTO<[CategoryEntityResponseDTO]>>
    func fetchGroupCategory(token: String, groupId: Int) -> Single<ResponseDTO<[CategoryEntityResponseDTO]>>
    func create(token: String, groupId: Int, category: CategoryRequestDTO) -> Single<ResponseDTO<CategoryResponseDataDTO>>
    func update(token: String, groupId: Int, categoryId: Int, category: CategoryRequestDTO) -> Single<ResponseDTO<CategoryResponseDataDTO>>
    func delete(token: String, groupId: Int, categoryId: Int) -> Single<ResponseDTO<CategoryResponseDataDTO>>
}

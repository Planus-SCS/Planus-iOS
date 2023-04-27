//
//  CategoryRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

protocol CategoryRepository {
    func read(token: String) -> Single<ResponseDTO<[CategoryEntityResponseDTO]>>
    func create(token: String, category: CategoryRequestDTO) -> Single<ResponseDTO<CategoryResponseDataDTO>>
    func update(token: String, id: Int, category: CategoryRequestDTO) -> Single<ResponseDTO<CategoryResponseDataDTO>>
    func delete(token: String, id: Int) -> Single<ResponseDTO<CategoryResponseDataDTO>>
}


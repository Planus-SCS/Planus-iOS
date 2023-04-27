//
//  CategoryRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

protocol CategoryRepository {
    func read(token: String) -> Single<TodoCategoryListResponseDTO>
    func create(token: String, category: TodoCategoryRequestDTO) -> Single<TodoCategoryResponseDTO>
    func update(token: String, id: Int, category: TodoCategoryRequestDTO) -> Single<TodoCategoryResponseDTO>
    func delete(token: String, id: Int) -> Single<TodoCategoryResponseDTO>
}


//
//  CategoryRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/26.
//

import Foundation
import RxSwift

protocol CategoryRepository {
    func read(token: String) -> Single<TodoCategoryReadResponseDTO>
    func create(token: String, category: TodoCategoryCreateRequestDTO) -> Single<TodoCategoryCreateResponseDTO>
    func update(token: String, id: Int, category: TodoCategoryUpdateRequestDTO) -> Single<TodoCategoryUpdateResponseDTO>
    func delete(token: String, id: Int) -> Single<TodoCategoryDeleteResponseDTO>
}


//
//  TodoRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

protocol TodoRepository {
    func createTodo(token: String, todo: TodoRequestDTO) -> Single<Int>
    func readTodo(token: String, from: Date, to: Date) -> Single<ResponseDTO<TodoListResponseDTO>>
    func updateTodo(token: String, id: Int, todo: TodoRequestDTO) -> Single<Int>
    func deleteTodo(token: String, id: Int) -> Single<Void>
}

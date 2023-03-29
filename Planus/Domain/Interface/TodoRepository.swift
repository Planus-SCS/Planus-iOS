//
//  TodoRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

protocol TodoRepository {
    func createTodo(todo: Todo) -> Single<Void>
    func readTodo(from: Date, to: Date) -> Single<[Todo]>
    func updateTodo(todo: Todo) -> Single<Void>
    func deleteTodo() -> Single<Void>
}

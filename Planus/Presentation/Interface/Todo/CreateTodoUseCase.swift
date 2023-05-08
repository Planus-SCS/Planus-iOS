//
//  CreateTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

protocol CreateTodoUseCase {
    var didCreateTodo: PublishSubject<Todo> { get }
    func execute(token: Token, todo: Todo) -> Single<Int>
}

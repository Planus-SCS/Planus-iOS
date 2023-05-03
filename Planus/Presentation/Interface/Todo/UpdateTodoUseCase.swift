//
//  UpdateTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

protocol UpdateTodoUseCase {
    var didUpdateTodo: PublishSubject<Todo> { get }
    func execute(token: Token, todo: Todo) -> Single<Void>
}

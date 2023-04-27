//
//  DeleteTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

protocol DeleteTodoUseCase {
    var didDeleteTodo: PublishSubject<Todo> { get }
    func execute(todo: Todo) -> Single<Void>
}

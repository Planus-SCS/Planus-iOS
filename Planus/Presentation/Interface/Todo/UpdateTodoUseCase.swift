//
//  UpdateTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/11.
//

import Foundation
import RxSwift

protocol UpdateTodoUseCase {
    var didUpdateTodo: PublishSubject<TodoUpdateComparator> { get }
    func execute(token: Token, todoUpdate: TodoUpdateComparator) -> Single<Void>
}

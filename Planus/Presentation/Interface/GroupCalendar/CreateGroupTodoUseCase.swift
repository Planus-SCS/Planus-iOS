//
//  CreateGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol CreateGroupTodoUseCase {
    var didCreateGroupTodo: PublishSubject<Todo> { get }
    func execute(token: Token, groupId: Int, todo: Todo) -> Single<Int>
}

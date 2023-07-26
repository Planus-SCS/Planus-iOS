//
//  DeleteGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol DeleteGroupTodoUseCase {
    func execute(token: Token, groupId: Int, todoId: Int) -> Single<Void>
}

//
//  DeleteGroupTodoUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol DeleteGroupTodoUseCase {
    var didDeleteGroupTodoWithIds: PublishSubject<(groupId: Int, todoId: Int)> { get } // groupId, todoId
    func execute(token: Token, groupId: Int, todoId: Int) -> Single<Void>
}

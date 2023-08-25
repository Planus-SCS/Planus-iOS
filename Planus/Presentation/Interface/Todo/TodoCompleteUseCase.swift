//
//  TodoCompleteUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/31.
//

import Foundation
import RxSwift

enum TodoCompletionType {
    case member
    case group(Int) //groupId를 연관값으로 전달
}

protocol TodoCompleteUseCase {
    var didCompleteTodo: PublishSubject<Todo> { get }
    func execute(token: Token, todo: Todo) -> Single<Void>
}

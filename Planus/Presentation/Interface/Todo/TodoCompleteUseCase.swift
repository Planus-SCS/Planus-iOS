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
    func execute(token: Token, todoId: Int, type: TodoCompletionType) -> Single<Void>
}

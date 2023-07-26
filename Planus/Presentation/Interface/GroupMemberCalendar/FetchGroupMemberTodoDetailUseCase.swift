//
//  FetchGroupMemberTodoDetailUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol FetchGroupMemberTodoDetailUseCase {
    func execute(token: Token, groupId: Int, memberId: Int, todoId: Int) -> Single<SocialTodoDetail>
}

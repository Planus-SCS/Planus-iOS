//
//  FetchMemberCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/16.
//

import Foundation
import RxSwift

protocol FetchMemberCategoryUseCase {
    func execute(token: Token, groupId: Int, memberId: Int) -> Single<[Category]>
}
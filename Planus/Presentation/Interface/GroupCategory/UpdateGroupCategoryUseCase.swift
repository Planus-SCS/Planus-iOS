//
//  UpdateGroupCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol UpdateGroupCategoryUseCase {
    func execute(token: Token, groupId: Int, categoryId: Int, category: Category) -> Single<Int>
}

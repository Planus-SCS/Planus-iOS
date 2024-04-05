//
//  CreateGroupCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol CreateGroupCategoryUseCase {
    func execute(token: Token, groupId: Int, category: Category) -> Single<Category>
}

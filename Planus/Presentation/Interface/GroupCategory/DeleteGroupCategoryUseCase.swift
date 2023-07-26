//
//  DeleteGroupCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol DeleteGroupCategoryUseCase {
    func execute(token: Token, groupId: Int, categoryId: Int) -> Single<Int>
}

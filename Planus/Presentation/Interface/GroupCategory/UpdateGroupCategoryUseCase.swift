//
//  UpdateGroupCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol UpdateGroupCategoryUseCase {
    var didUpdateCategoryWithGroupId: PublishSubject<(groupId: Int, category: Category)> { get }
    func execute(token: Token, groupId: Int, categoryId: Int, category: Category) -> Single<Int>
}

//
//  FetchAllGroupCategoryListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/30.
//

import Foundation
import RxSwift

protocol FetchAllGroupCategoryListUseCase {
    func execute(token: Token) -> Single<[Category]>
}

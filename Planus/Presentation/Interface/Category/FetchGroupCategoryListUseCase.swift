//
//  FetchGroupCategoryListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/30.
//

import Foundation
import RxSwift

protocol FetchGroupCategoryListUseCase {
    func execute(token: Token) -> Single<[Category]>
}

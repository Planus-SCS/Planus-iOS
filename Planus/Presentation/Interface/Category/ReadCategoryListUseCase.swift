//
//  ReadTodoCategoryUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

protocol ReadCategoryListUseCase {
    func execute(token: Token) -> Single<[Category]>
}

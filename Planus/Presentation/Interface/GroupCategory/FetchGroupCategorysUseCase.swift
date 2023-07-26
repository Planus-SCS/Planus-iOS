//
//  FetchGroupCategorysUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/26.
//

import Foundation
import RxSwift

protocol FetchGroupCategorysUseCase {
    func execute(token: Token, groupId: Int) -> Single<[Category]>
}

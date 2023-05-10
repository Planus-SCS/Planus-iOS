//
//  FetchMyGroupListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation
import RxSwift

protocol FetchMyGroupListUseCase {
    func execute(token: Token) -> Single<[MyGroupSummary]>
}

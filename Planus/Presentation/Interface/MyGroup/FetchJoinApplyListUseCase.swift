//
//  FetchJoinApplyListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

protocol FetchJoinApplyListUseCase {
    func execute(token: Token) -> Single<[MyGroupJoinAppliance]>
}

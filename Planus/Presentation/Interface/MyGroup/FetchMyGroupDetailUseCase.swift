//
//  FetchMyGroupDetailUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation
import RxSwift

protocol FetchMyGroupDetailUseCase {
    func execute(token: Token, groupId: Int) -> Single<MyGroupDetail>
}

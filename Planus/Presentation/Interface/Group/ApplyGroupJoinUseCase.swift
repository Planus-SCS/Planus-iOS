//
//  ApplyGroupJoinUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation
import RxSwift

protocol ApplyGroupJoinUseCase {
    func execute(token: Token, groupId: Int) -> Single<Void>
}

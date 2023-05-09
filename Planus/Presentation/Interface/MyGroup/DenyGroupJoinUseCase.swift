//
//  DenyGroupJoinUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation
import RxSwift

protocol DenyGroupJoinUseCase {
    func execute(token: Token, applyId: Int) -> Single<Void>
}

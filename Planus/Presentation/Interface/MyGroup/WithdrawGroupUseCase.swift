//
//  WithdrawGroupUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/29.
//

import Foundation
import RxSwift

protocol WithdrawGroupUseCase {
    var didWithdrawGroup: PublishSubject<Int> { get }
    func execute(token: Token, groupId: Int) -> Single<Void>
}

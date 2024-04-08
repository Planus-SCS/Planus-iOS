//
//  DefaultWithdrawGroupUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/29.
//

import Foundation
import RxSwift

final class DefaultWithdrawGroupUseCase: WithdrawGroupUseCase {

    let myGroupRepository: MyGroupRepository
    let didWithdrawGroup = PublishSubject<Int>()
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupId: Int) -> Single<Void> {
        myGroupRepository
            .withdrawGroup(token: token.accessToken, groupId: groupId)
            .do(onSuccess: { [weak self] _ in
                self?.didWithdrawGroup.onNext(groupId)
            })
            .map { _ in
                return ()
            }
    }
}

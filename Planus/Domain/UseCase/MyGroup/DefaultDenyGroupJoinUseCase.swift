//
//  DefaultDenyGroupJoinUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation
import RxSwift

class DefaultDenyGroupJoinUseCase: DenyGroupJoinUseCase {
    let myGroupRepository: MyGroupRepository
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, applyId: Int) -> Single<Void> {
        myGroupRepository
            .denyApply(token: token.accessToken, applyId: applyId)
            .map { _ in
                return ()
            }
    }
}

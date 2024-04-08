//
//  DefaultAcceptGroupJoinUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation
import RxSwift

final class DefaultAcceptGroupJoinUseCase: AcceptGroupJoinUseCase {
    let myGroupRepository: MyGroupRepository
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, applyId: Int) -> Single<Void> {
        myGroupRepository
            .acceptApply(token: token.accessToken, applyId: applyId)
            .map { _ in
                return ()
            }
    }
}

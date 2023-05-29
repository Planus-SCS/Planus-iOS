//
//  DefaultApplyGroupJoinUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation
import RxSwift

class DefaultApplyGroupJoinUseCase: ApplyGroupJoinUseCase {
    let groupRepository: GroupRepository
    
    init(groupRepository: GroupRepository) {
        self.groupRepository = groupRepository
    }
    
    func execute(token: Token, groupId: Int) -> Single<Void> {
        groupRepository
            .joinGroup(token: token.accessToken, id: groupId)
            .map { _ in
                return ()
            }
    }
}

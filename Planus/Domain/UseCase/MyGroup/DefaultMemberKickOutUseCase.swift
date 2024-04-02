//
//  DefaultMemberKickOutUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/13.
//

import Foundation
import RxSwift

class DefaultMemberKickOutUseCase: MemberKickOutUseCase {

    let myGroupRepository: MyGroupRepository
    
    var didKickOutMemberAt = PublishSubject<(Int, Int)>()
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupId: Int, memberId: Int) -> Single<Void> {
        myGroupRepository
            .kickOutMember(token: token.accessToken, groupId: groupId, memberId: memberId)
            .map { [weak self] _ in
                self?.didKickOutMemberAt.onNext((groupId, memberId))
                return ()
            }
    }
}

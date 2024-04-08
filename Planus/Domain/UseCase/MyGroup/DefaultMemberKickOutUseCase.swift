//
//  DefaultMemberKickOutUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/13.
//

import Foundation
import RxSwift

final class DefaultMemberKickOutUseCase: MemberKickOutUseCase {

    let myGroupRepository: MyGroupRepository
    let didKickOutMemberAt = PublishSubject<(Int, Int)>()
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupId: Int, memberId: Int) -> Single<Void> {
        myGroupRepository
            .kickOutMember(token: token.accessToken, groupId: groupId, memberId: memberId)
            .do(onSuccess: { [weak self] _ in
                self?.didKickOutMemberAt.onNext((groupId, memberId))
            })
            .map { _ in
                return ()
            }
    }
}

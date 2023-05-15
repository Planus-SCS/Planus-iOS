//
//  DefaultFetchMyGroupMemberListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation
import RxSwift

class DefaultFetchMyGroupMemberListUseCase: FetchMyGroupMemberListUseCase {
    let myGroupRepository: MyGroupRepository
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupId: Int) -> Single<[MyMember]> {
        myGroupRepository
            .fetchMyGroupMemberList(token: token.accessToken, groupId: groupId)
            .map {
                $0.data.map { $0.toDomain() }
            }
    }
}
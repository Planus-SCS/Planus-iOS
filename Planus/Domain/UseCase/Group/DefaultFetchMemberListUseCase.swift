//
//  DefaultFetchMemberListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

class DefaultFetchMemberListUseCase: FetchMemberListUseCase {
    let groupRepository: GroupRepository
    
    init(groupRepository: GroupRepository) {
        self.groupRepository = groupRepository
    }
    
    func execute(token: Token, groupId: Int) -> Single<[Member]> {
        groupRepository
            .fetchMemberList(token: token.accessToken, id: groupId)
            .map { responseDTO in
                return responseDTO.data.map { $0.toDomain() }
            }
    }
}

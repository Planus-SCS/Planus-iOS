//
//  DefaultFetchUnJoinedGroupUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

class DefaultFetchUnJoinedGroupUseCase: FetchUnJoinedGroupUseCase {
    let groupRepository: GroupRepository
    
    init(groupRepository: GroupRepository) {
        self.groupRepository = groupRepository
    }
    
    func execute(token: Token, id: Int) -> Single<UnJoinedGroupDetail> {
        return groupRepository
            .fetchGroup(token: token.accessToken, id: id)
            .map { dto in
                return dto.data.toDomain()
            }
    }
}
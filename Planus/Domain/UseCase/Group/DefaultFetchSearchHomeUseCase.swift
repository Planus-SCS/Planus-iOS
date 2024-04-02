//
//  DefaultFetchSearchHomeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/24.
//

import Foundation
import RxSwift

final class DefaultFetchSearchHomeUseCase: FetchSearchHomeUseCase {
    let groupRepository: GroupRepository
    
    init(groupRepository: GroupRepository) {
        self.groupRepository = groupRepository
    }
    
    func execute(token: Token, page: Int, size: Int) -> Single<[GroupSummary]> {
        groupRepository
            .fetchSearchHome(token: token.accessToken, page: page, size: size)
            .map {
                $0.data.map {
                    return $0.toDomain()
                }
            }
    }
}

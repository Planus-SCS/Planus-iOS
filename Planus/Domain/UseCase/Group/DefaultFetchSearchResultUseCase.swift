//
//  DefaultFetchSearchResultUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/27.
//

import Foundation
import RxSwift

class DefaultFetchSearchResultUseCase: FetchSearchResultUseCase {
    let groupRepository: GroupRepository
    
    init(groupRepository: GroupRepository) {
        self.groupRepository = groupRepository
    }
    
    func execute(token: Token, keyWord: String, page: Int, size: Int) -> Single<[UnJoinedGroupSummary]> {
        groupRepository
            .fetchSearchResult(
                token: token.accessToken,
                keyWord: keyWord,
                page: page,
                size: size
            )
            .map {
                $0.data.map {
                    return $0.toDomain()
                }
            }
    }
}

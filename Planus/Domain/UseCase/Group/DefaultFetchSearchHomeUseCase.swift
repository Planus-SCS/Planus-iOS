//
//  DefaultFetchSearchHomeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/24.
//

import Foundation
import RxSwift

class DefaultFetchSearchHomeUseCase {
    let groupRepository: GroupRepository
    
    init(groupRepository: GroupRepository) {
        self.groupRepository = groupRepository
    }
    
    func execute(page: Int, size: Int) -> Single<[UnJoinedGroupSummary]> {
        groupRepository
            .fetchSearchHome(page: page, size: size)
            .map {
                $0.data.map {
                    return $0.toDomain()
                }
            }
    }
}

//
//  DefaultFetchMyGroupListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation
import RxSwift

final class DefaultFetchMyGroupListUseCase: FetchMyGroupListUseCase {
    let myGroupRepository: MyGroupRepository
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token) -> Single<[MyGroupSummary]> {
        myGroupRepository
            .fetchGroupSummaryList(token: token.accessToken)
            .map {
                $0.data.map {
                    $0.toDomain()
                }
            }
    }
}

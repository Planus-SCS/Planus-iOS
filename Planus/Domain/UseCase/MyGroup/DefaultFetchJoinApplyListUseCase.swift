//
//  DefaultFetchJoinApplyListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

final class DefaultFetchJoinApplyListUseCase: FetchJoinApplyListUseCase {
    private let myGroupRepository: MyGroupRepository
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token) -> Single<[MyGroupJoinAppliance]> {
        return myGroupRepository
            .fetchJoinApplyList(token: token.accessToken)
            .map {
                $0.data.map { $0.toDomain() }
            }
    }
}

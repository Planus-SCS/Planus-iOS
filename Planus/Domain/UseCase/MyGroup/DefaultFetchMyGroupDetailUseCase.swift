//
//  DefaultFetchMyGroupDetailUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/12.
//

import Foundation
import RxSwift

class DefaultFetchMyGroupDetailUseCase: FetchMyGroupDetailUseCase {
    let myGroupRepository: MyGroupRepository
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupId: Int) -> Single<MyGroupDetail> {
        myGroupRepository
            .fetchMyGroupDetail(token: token.accessToken, groupId: groupId)
            .map {
                $0.data.toDomain()
            }
    }
}

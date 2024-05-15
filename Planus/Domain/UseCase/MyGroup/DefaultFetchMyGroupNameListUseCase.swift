//
//  DefaultFetchMyGroupNameListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/17.
//

import Foundation
import RxSwift

final class DefaultFetchMyGroupNameListUseCase: FetchMyGroupNameListUseCase {
    private let myGroupRepo: MyGroupRepository
    
    init(myGroupRepo: MyGroupRepository) {
        self.myGroupRepo = myGroupRepo
    }
    
    func execute(token: Token) -> Single<[GroupName]> {
        return myGroupRepo
            .fetchGroupNameList(token: token.accessToken)
            .map {
                $0.data.map { $0.toDomain() }
            }
    }
}

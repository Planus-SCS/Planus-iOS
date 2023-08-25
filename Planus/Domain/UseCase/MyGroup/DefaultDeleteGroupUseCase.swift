//
//  DefaultDeleteGroupUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/29.
//

import Foundation
import RxSwift

class DefaultDeleteGroupUseCase: DeleteGroupUseCase {
    static let shared = DefaultDeleteGroupUseCase(myGroupRepository: DefaultMyGroupRepository(apiProvider: NetworkManager()))
    let myGroupRepository: MyGroupRepository
    
    var didDeleteGroupWithId = PublishSubject<Int>()
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupId: Int) -> Single<Void> {
        myGroupRepository
            .removeGroup(token: token.accessToken, groupId: groupId)
            .map { [weak self] _ in
                self?.didDeleteGroupWithId.onNext(groupId)
                return
            }
    }
}

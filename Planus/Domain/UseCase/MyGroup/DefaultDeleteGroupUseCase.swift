//
//  DefaultDeleteGroupUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/29.
//

import Foundation
import RxSwift

final class DefaultDeleteGroupUseCase: DeleteGroupUseCase {

    private let myGroupRepository: MyGroupRepository
    let didDeleteGroupWithId = PublishSubject<Int>()
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupId: Int) -> Single<Void> {
        myGroupRepository
            .removeGroup(token: token.accessToken, groupId: groupId)
            .do(onSuccess: { [weak self] _ in
                self?.didDeleteGroupWithId.onNext(groupId)
            })
            .map { _ in
                return
            }
    }
}

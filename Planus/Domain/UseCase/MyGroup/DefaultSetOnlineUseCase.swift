//
//  DefaultSetOnlineUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/10.
//

import Foundation
import RxSwift

class DefaultSetOnlineUseCase: SetOnlineUseCase {
    static let shared = DefaultSetOnlineUseCase(myGroupRepository: DefaultMyGroupRepository(apiProvider: NetworkManager()))
    let myGroupRepository: MyGroupRepository
    
    var didChangeOnlineState = PublishSubject<(Int, Int)>()
    
    private init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupId: Int) -> Single<Void> {
        myGroupRepository
            .changeOnlineState(token: token.accessToken, groupId: groupId)
            .map { [weak self] dto in
                self?.didChangeOnlineState.onNext((groupId, dto.data.memberId))
                return ()
            }
    }
}

//
//  DefaultGroupCreateUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

class DefaultGroupCreateUseCase: GroupCreateUseCase {
    let myGroupRepository: MyGroupRepository
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupCreate: GroupCreate, image: ImageFile) -> Single<Void> {
        myGroupRepository.create(
            token: token.accessToken,
            groupCreateRequestDTO: groupCreate.toDTO(),
            image: image
        ).map { _ in
            return ()
        }
    }
}

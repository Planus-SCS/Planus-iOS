//
//  DefaultGroupCreateUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

final class DefaultGroupCreateUseCase: GroupCreateUseCase {
    
    let myGroupRepository: MyGroupRepository
    let didCreateGroup = PublishSubject<Void>()
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupCreate: MyGroupCreationInfo, image: ImageFile) -> Single<Int> {
        myGroupRepository.create(
            token: token.accessToken,
            groupCreateRequestDTO: groupCreate.toDTO(),
            image: image
        )
        .do(onSuccess: { [weak self] _ in
            self?.didCreateGroup.onNext(())
        })
        .map { dto in
            return dto.data.groupId
        }
    }
}

//
//  DefaultGroupCreateUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/09.
//

import Foundation
import RxSwift

class DefaultGroupCreateUseCase: GroupCreateUseCase {
    
    static let shared = DefaultGroupCreateUseCase(myGroupRepository: DefaultMyGroupRepository(apiProvider: NetworkManager()))
    let myGroupRepository: MyGroupRepository
    
    var didCreateGroup = PublishSubject<Void>()
    
    init(myGroupRepository: MyGroupRepository) {
        self.myGroupRepository = myGroupRepository
    }
    
    func execute(token: Token, groupCreate: MyGroupCreationInfo, image: ImageFile) -> Single<Int> {
        myGroupRepository.create(
            token: token.accessToken,
            groupCreateRequestDTO: groupCreate.toDTO(),
            image: image
        ).map { [weak self] dto in
            self?.didCreateGroup.onNext(())
            return dto.data.groupId
        }
    }
}

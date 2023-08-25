//
//  DefaultRemoveProfileUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/24.
//

import Foundation
import RxSwift

class DefaultRemoveProfileUseCase: RemoveProfileUseCase {
    let profileRepository: ProfileRepository
    
    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }
    
    func execute(token: Token) -> Single<Void> {
        return profileRepository
            .removeProfile(token: token.accessToken)
            .map { _ in () }
    }
}

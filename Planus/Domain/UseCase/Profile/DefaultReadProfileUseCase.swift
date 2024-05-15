//
//  DefaultReadProfileUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

final class DefaultReadProfileUseCase: ReadProfileUseCase {
    private let profileRepository: ProfileRepository
    
    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }
    
    func execute(token: Token) -> Single<Profile> {
        return profileRepository
            .readProfile(token: token.accessToken)
            .map {
            return $0.data.toDomain()
        }
    }
}

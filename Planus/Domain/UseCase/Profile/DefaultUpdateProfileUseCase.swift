//
//  DefaultUpdateProfileUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

final class DefaultUpdateProfileUseCase: UpdateProfileUseCase {
    
    let profileRepository: ProfileRepository
    let didUpdateProfile = PublishSubject<Profile>()
    
    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }
    
    func execute(
        token: Token,
        name: String,
        introduce: String?,
        isImageRemoved: Bool,
        image: ImageFile?
    ) -> Single<Void> {
        return profileRepository.updateProfile(
            token: token.accessToken,
            requestDTO: ProfileRequestDTO(
                nickname: name,
                description: introduce,
                profileImageRemove: isImageRemoved
            ),
            profileImage: image)
        .do(onSuccess: { [weak self] dto in
            let profile = dto.data.toDomain()
            self?.didUpdateProfile.onNext(profile)
        })
        .map { _ in
            return ()
        }
    }
}

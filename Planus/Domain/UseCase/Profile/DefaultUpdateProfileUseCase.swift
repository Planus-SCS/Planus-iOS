//
//  DefaultUpdateProfileUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/08.
//

import Foundation
import RxSwift

class DefaultUpdateProfileUseCase: UpdateProfileUseCase {
    
    static let shared = DefaultUpdateProfileUseCase(profileRepository: DefaultProfileRepository(apiProvider: NetworkManager()))
    
    let profileRepository: ProfileRepository
    
    var didUpdateProfile = PublishSubject<Profile>()
    
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
            profileImage: image).map { [weak self] in
                let profile = $0.data.toDomain()
                self?.didUpdateProfile.onNext(profile)
                return ()
            }
    }
}

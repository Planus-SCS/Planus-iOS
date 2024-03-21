//
//  DomainAssembly+Profile.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

class ProfileDomainAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(ReadProfileUseCase.self) { r in
            let profileRepo = r.resolve(ProfileRepository.self)!
            return DefaultReadProfileUseCase(profileRepository: profileRepo)
        }
        
        container.register(UpdateProfileUseCase.self) { r in
            let profileRepo = r.resolve(ProfileRepository.self)!
            return DefaultUpdateProfileUseCase(profileRepository: profileRepo)
        }.inObjectScope(.container)
        
        container.register(RemoveProfileUseCase.self) { r in
            let profileRepo = r.resolve(ProfileRepository.self)!
            return DefaultRemoveProfileUseCase(profileRepository: profileRepo)
        }
    }
    
}

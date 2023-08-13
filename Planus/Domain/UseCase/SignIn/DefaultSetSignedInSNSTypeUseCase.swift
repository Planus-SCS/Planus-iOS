//
//  DefaultSetSignedInSNSTypeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/13.
//

import Foundation

class DefaultSetSignedInSNSTypeUseCase: SetSignedInSNSTypeUseCase {
    let socialAuthRepository: SocialAuthRepository
    
    init(socialAuthRepository: SocialAuthRepository) {
        self.socialAuthRepository = socialAuthRepository
    }
    
    func execute(type: SocialAuthType) {
        socialAuthRepository.setSignedInSNSType(type: type)
    }
}

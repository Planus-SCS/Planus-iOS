//
//  DefaultSetSignedInSNSTypeUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/13.
//

import Foundation

final class DefaultSetSignedInSNSTypeUseCase: SetSignedInSNSTypeUseCase {
    private let socialAuthRepository: SocialAuthRepository
    
    init(socialAuthRepository: SocialAuthRepository) {
        self.socialAuthRepository = socialAuthRepository
    }
    
    func execute(type: SocialAuthType) {
        socialAuthRepository.setSignedInSNSType(type: type)
    }
}

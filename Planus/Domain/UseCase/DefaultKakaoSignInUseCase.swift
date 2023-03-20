//
//  DefaultKakaoSignInUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

class DefaultKakaoSignInUseCase {
    
    let socialAuthRepository: SocialAuthRepository
    
    init(socialAuthRepository: SocialAuthRepository) {
        self.socialAuthRepository = socialAuthRepository
    }
    
    func execute() -> Observable<String>? {
        return socialAuthRepository.kakaoSignIn()
    }
}

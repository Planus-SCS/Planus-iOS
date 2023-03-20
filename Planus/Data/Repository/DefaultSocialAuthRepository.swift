//
//  SocialAuthRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift
import KakaoSDKUser
import RxKakaoSDKUser

class DefaultSocialAuthRepository: SocialAuthRepository {
    func kakaoSignIn() -> Observable<String>? {
        if UserApi.isKakaoTalkLoginAvailable() {
            return UserApi.shared
                .rx
                .loginWithKakaoTalk()
                .map {
                    return $0.accessToken
                }
        }
        return nil
    }
    
    func googleSignIn() {
        
    }
    
    func appleSignIn() {
        
    }
}

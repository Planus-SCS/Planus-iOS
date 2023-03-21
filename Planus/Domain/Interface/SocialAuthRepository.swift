//
//  SocialAuthRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/21.
//

import Foundation
import RxSwift

protocol SocialAuthRepository {
    func kakaoSignIn(code: String) -> Single<Data>
    func googleSignIn()
    func appleSignIn()
}

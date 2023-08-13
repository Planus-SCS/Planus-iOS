//
//  RevokeAppleTokenUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/14.
//

import Foundation
import RxSwift

protocol RevokeAppleTokenUseCase {
    func execute(authorizationCode: String) -> Single<Void>
}

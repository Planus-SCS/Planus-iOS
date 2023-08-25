//
//  AppleSignInUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/07.
//

import Foundation
import RxSwift

protocol AppleSignInUseCase {
    func execute(identityToken: String, fullName: PersonNameComponents?) -> Single<Token>
}

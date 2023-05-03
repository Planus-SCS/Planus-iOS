//
//  GoogleSignInUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation
import RxSwift

protocol GoogleSignInUseCase {
    func execute(code: String) -> Single<Token>
}

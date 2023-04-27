//
//  DefaultRefreshTokenUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

class DefaultRefreshTokenUseCase: RefreshTokenUseCase {
    let tokenRepository: TokenRepository
    
    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }
    
    func execute() -> Single<Void>? {
        return tokenRepository.refresh()
    }
}

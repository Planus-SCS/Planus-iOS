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
    
    func execute() -> Single<Token>? {
        return tokenRepository
            .refresh()?
            .map {
                return $0.data.toDomain()
            }
    }
}

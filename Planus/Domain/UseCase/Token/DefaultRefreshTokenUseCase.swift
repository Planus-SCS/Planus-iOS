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
    
    func execute() -> Single<Token> {
        return tokenRepository
            .refresh()
            .map { [weak self] dto in
                let token = dto.data.toDomain()
                self?.tokenRepository.set(token: token)
                print("new ref token: ", token.refreshToken)
                print("new saved ref token: ", self?.tokenRepository.get()?.refreshToken)
                return token
            }
    }
}

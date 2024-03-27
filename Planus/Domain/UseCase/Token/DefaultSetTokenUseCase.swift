//
//  DefaultSetTokenUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation

class DefaultSetTokenUseCase: SetTokenUseCase {
    let tokenRepository: TokenRepository
    
    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }
    
    func execute(token: Token) {
        return tokenRepository.set(token: token)
    }
}

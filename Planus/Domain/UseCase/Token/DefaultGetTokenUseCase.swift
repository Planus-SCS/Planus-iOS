//
//  File.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation

class DefaultGetTokenUseCase: GetTokenUseCase {
    let tokenRepository: TokenRepository
    
    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }
    
    func execute() -> Token? {
        return tokenRepository.get()
    }
}

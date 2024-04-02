//
//  DefaultRemoveTokenUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/07/24.
//

import Foundation

final class DefaultRemoveTokenUseCase: RemoveTokenUseCase {
    let tokenRepository: TokenRepository
    
    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }
    
    func execute() {
        tokenRepository.delete()
    }
}

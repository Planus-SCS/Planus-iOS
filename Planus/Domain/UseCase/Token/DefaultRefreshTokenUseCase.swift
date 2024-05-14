//
//  DefaultRefreshTokenUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

final class DefaultRefreshTokenUseCase: RefreshTokenUseCase {
    private let tokenRepository: TokenRepository
    
    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }
    
    func execute() -> Single<Token> {
        return tokenRepository
            .refresh()
            .map { $0.toDomain() }
            .do(onSuccess: { [weak self] token in
                self?.tokenRepository.set(token: token)
            })
    }
}

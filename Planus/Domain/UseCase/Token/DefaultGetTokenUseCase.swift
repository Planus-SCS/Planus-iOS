//
//  File.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

final class DefaultGetTokenUseCase: GetTokenUseCase {
    let tokenRepository: TokenRepository
    
    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }
    
    func execute() -> Single<Token> {
        Single.create { [weak self] emitter -> Disposable in
            guard let token = self?.tokenRepository.get() else {
                emitter(.failure(TokenError.noTokenExist))
                return Disposables.create()
            }
            emitter(.success(token))
            return Disposables.create()
        }
    }
}

//
//  DefaultExecuteWithTokenUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 3/22/24.
//

import Foundation
import RxSwift

class DefaultExecuteWithTokenUseCase: ExecuteWithTokenUseCase {
    
    let tokenRepository: TokenRepository
    
    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }
    
    func execute<T>(executable: @escaping (Token) -> Single<T>) -> PrimitiveSequence<SingleTrait, T> {
        return Single<Token>.create { [weak self] emitter -> Disposable in
            guard let token = self?.tokenRepository.get() else {
                emitter(.failure(TokenError.noTokenExist))
                return Disposables.create()
            }
            emitter(.success(token))
            return Disposables.create()
        }
        .flatMap { [weak self] token -> Single<T> in
            guard let self else { throw DefaultError.noCapturedSelf }
            return executable(token)
        }
        .handleRetry(
            retryObservable: { () -> PrimitiveSequence<SingleTrait, Token> in
                tokenRepository
                    .refresh()
                    .map { [weak self] dto in
                        let token = dto.data.toDomain()
                        self?.tokenRepository.set(token: token)
                        return token
                    }
            }(),
            errorType: NetworkManagerError.tokenExpired
        )
    }
}

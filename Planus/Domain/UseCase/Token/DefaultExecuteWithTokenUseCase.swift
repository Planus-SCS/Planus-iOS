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
    
    func execute<T>(executable: @escaping (Token) -> Single<T>?) -> Single<T> {
        return getToken()
            .flatMap { token -> Single<T> in
                return executable(token) ?? Single.error(DefaultError.noThingExecutable)
            }
            .handleRetry(
                retryObservable: self.refreshTokenIfNeeded(),
                errorType: NetworkManagerError.tokenExpired
            )
    }
}

private extension DefaultExecuteWithTokenUseCase {
    enum DefaultError: Error {
        case noThingExecutable
    }
    
    func getToken() -> Single<Token> {
        return Single<Token>.create { [weak self] emitter -> Disposable in
            guard let token = self?.tokenRepository.get() else {
                emitter(.failure(TokenError.noTokenExist))
                return Disposables.create()
            }
            emitter(.success(token))
            return Disposables.create()
        }
    }
    
    func refreshTokenIfNeeded() -> Single<Token> {
        return tokenRepository.refresh()
            .map { [weak self] dto in
                let token = dto.data.toDomain()
                self?.tokenRepository.set(token: token)
                return token
            }
    }
}

//
//  File.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/27.
//

import Foundation
import RxSwift

final class DefaultGetTokenUseCase: GetTokenUseCase {
    private let tokenRepository: TokenRepository
    
    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }
    
    func execute() -> Single<Token> {
        Single.create { [weak self] emitter -> Disposable in
            guard let token = self?.tokenRepository.get() else {
                emitter(.failure(TokenError.noneExist))
                return Disposables.create()
            }
            emitter(.success(token))
            return Disposables.create()
        }
    }
}

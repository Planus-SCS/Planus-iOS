//
//  DomainAssembly+Token.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {

    func assembleToken(container: Container) {
        container.register(GetTokenUseCase.self) { r in
            let tokenRepository = r.resolve(TokenRepository.self)!
            return DefaultGetTokenUseCase(tokenRepository: tokenRepository)
        }
        
        container.register(RefreshTokenUseCase.self) { r in
            let tokenRepository = r.resolve(TokenRepository.self)!
            return DefaultRefreshTokenUseCase(tokenRepository: tokenRepository)
        }
        
        container.register(SetTokenUseCase.self) { r in
            let tokenRepository = r.resolve(TokenRepository.self)!
            return DefaultSetTokenUseCase(tokenRepository: tokenRepository)
        }
        
        container.register(RemoveTokenUseCase.self) { r in
            let tokenRepository = r.resolve(TokenRepository.self)!
            return DefaultRemoveTokenUseCase(tokenRepository: tokenRepository)
        }
    }
    
}

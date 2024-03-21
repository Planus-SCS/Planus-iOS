//
//  InfraAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

public struct InfraAssembly: Assembly {
    public func assemble(container: Swinject.Container) {
        container.register(KeyChainManager.self) { _ in
            return KeyChainManager()
        }
        
        container.register(UserDefaultsManager.self) { _ in
            return UserDefaultsManager()
        }
        
        container.register(APIProvider.self) { _ in
            return NetworkManager()
        }
    }
    
    
}

//
//  DataAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/8/24.
//

import Foundation
import Swinject

public struct DataAssembly: Assembly {
    public func assemble(container: Swinject.Container) {
        container.register(SocialAuthRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            let keyValueStorage = container.resolve(KeyValueStorage.self)!
            return DefaultSocialAuthRepository(apiProvider: apiProvider, keyValueStorage: keyValueStorage)
        }
        
        container.register(TodoRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            return TestTodoDetailRepository(apiProvider: apiProvider)
        }
        
        container.register(CategoryRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            return DefaultCategoryRepository(apiProvider: apiProvider)
        }
        
        container.register(TokenRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            let keyChainManager = container.resolve(KeyChainManager.self)!
            return DefaultTokenRepository(apiProvider: apiProvider, keyChainManager: keyChainManager)
        }
        
        container.register(ProfileRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            return DefaultProfileRepository(apiProvider: apiProvider)
        }
        
        container.register(ImageRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            return DefaultImageRepository(apiProvider: apiProvider)
        }
        
        container.register(MyGroupRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            return DefaultMyGroupRepository(apiProvider: apiProvider)
        }
        
        container.register(GroupRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            return DefaultGroupRepository(apiProvider: apiProvider)
        }
        
        container.register(GroupMemberCalendarRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            return DefaultGroupMemberCalendarRepository(apiProvider: apiProvider)
        }
        
        container.register(GroupCalendarRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            return DefaultGroupCalendarRepository(apiProvider: apiProvider)
        }
        
        container.register(RecentQueryRepository.self) { _ in
            return DefaultRecentQueryRepository()
        }
        
        container.register(GroupCategoryRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            return DefaultGroupCategoryRepository(apiProvider: apiProvider)
        }
        
        container.register(FCMRepository.self) { _ in
            let apiProvider = container.resolve(APIProvider.self)!
            return DefaultFCMRepository(apiProvider: apiProvider)
        }
    }
    
    
}

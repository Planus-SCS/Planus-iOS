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
        container.register(SocialAuthRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            let userDefaultsManager = r.resolve(UserDefaultsManager.self)!
            return DefaultSocialAuthRepository(apiProvider: apiProvider, keyValueStorage: userDefaultsManager)
        }
        
        container.register(TodoRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            return TestTodoDetailRepository(apiProvider: apiProvider)
        }
        
        container.register(CategoryRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            return DefaultCategoryRepository(apiProvider: apiProvider)
        }
        
        container.register(TokenRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            let keyChainManager = r.resolve(KeyChainManager.self)!
            return DefaultTokenRepository(apiProvider: apiProvider, keyValueStorage: keyChainManager)
        }
        
        container.register(ProfileRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            return DefaultProfileRepository(apiProvider: apiProvider)
        }
        
        container.register(ImageRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            return DefaultImageRepository(apiProvider: apiProvider)
        }
        
        container.register(MyGroupRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            return DefaultMyGroupRepository(apiProvider: apiProvider)
        }
        
        container.register(GroupRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            return DefaultGroupRepository(apiProvider: apiProvider)
        }
        
        container.register(GroupMemberCalendarRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            return DefaultGroupMemberCalendarRepository(apiProvider: apiProvider)
        }
        
        container.register(GroupCalendarRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            return DefaultGroupCalendarRepository(apiProvider: apiProvider)
        }
        
        container.register(RecentQueryRepository.self) { _ in
            return DefaultRecentQueryRepository()
        }
        
        container.register(GroupCategoryRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            return DefaultGroupCategoryRepository(apiProvider: apiProvider)
        }
        
        container.register(FCMRepository.self) { r in
            let apiProvider = r.resolve(APIProvider.self)!
            let userDefaultsManager = r.resolve(UserDefaultsManager.self)!
            return DefaultFCMRepository(apiProvider: apiProvider, keyValueStorage: userDefaultsManager)
        }
    }
    
    
}

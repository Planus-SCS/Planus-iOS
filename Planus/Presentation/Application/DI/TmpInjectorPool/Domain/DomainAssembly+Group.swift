//
//  DomainAssembly+Group.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {
    
    func assembleGroup(container: Container) {
        container.register(FetchUnJoinedGroupUseCase.self) { r in
            let groupRepository = r.resolve(GroupRepository.self)!
            return DefaultFetchUnJoinedGroupUseCase(groupRepository: groupRepository)
        }
        
        container.register(FetchMemberListUseCase.self) { r in
            let groupRepository = r.resolve(GroupRepository.self)!
            return DefaultFetchMemberListUseCase(groupRepository: groupRepository)
        }
        
        container.register(ApplyGroupJoinUseCase.self) { r in
            let groupRepository = r.resolve(GroupRepository.self)!
            return DefaultApplyGroupJoinUseCase(groupRepository: groupRepository)
        }
        
        container.register(FetchSearchHomeUseCase.self) { r in
            let groupRepository = r.resolve(GroupRepository.self)!
            return DefaultFetchSearchHomeUseCase(groupRepository: groupRepository)
        }
        
        container.register(FetchSearchResultUseCase.self) { r in
            let groupRepository = r.resolve(GroupRepository.self)!
            return DefaultFetchSearchResultUseCase(groupRepository: groupRepository)
        }
        
        container.register(GenerateGroupLinkUseCase.self) { _ in
            return DefaultGenerateGroupLinkUseCase()
        }
    }
    
}

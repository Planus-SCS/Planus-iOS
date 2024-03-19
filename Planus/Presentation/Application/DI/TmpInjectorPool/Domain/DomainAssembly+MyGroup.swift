//
//  DomainAssembly+MyGroup.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {
    
    func assembleMyGroup(container: Container) {
        container.register(AcceptGroupJoinUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultAcceptGroupJoinUseCase(myGroupRepository: myGroupRepository)
        }
        
        container.register(DenyGroupJoinUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultDenyGroupJoinUseCase(myGroupRepository: myGroupRepository)
        }
        
        container.register(GroupCreateUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultGroupCreateUseCase(myGroupRepository: myGroupRepository)
        }
        
        container.register(FetchJoinApplyListUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultFetchJoinApplyListUseCase(myGroupRepository: myGroupRepository)
        }
        
        container.register(FetchMyGroupListUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultFetchMyGroupListUseCase(myGroupRepository: myGroupRepository)
        }
        
        container.register(SetOnlineUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultSetOnlineUseCase(myGroupRepository: myGroupRepository)
        }.inObjectScope(.container)
        
        container.register(FetchMyGroupDetailUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultFetchMyGroupDetailUseCase(myGroupRepository: myGroupRepository)
        }
        
        container.register(FetchMyGroupMemberListUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultFetchMyGroupMemberListUseCase(myGroupRepository: myGroupRepository)
        }
        
        container.register(UpdateNoticeUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultUpdateNoticeUseCase(myGroupRepository: myGroupRepository)
        }.inObjectScope(.container)
        
        container.register(MemberKickOutUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultMemberKickOutUseCase(myGroupRepository: myGroupRepository)
        }
        
        container.register(UpdateGroupInfoUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultUpdateGroupInfoUseCase(myGroupRepository: myGroupRepository)
        }.inObjectScope(.container)
        
        container.register(FetchMyGroupNameListUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultFetchMyGroupNameListUseCase(myGroupRepo: myGroupRepository)
        }
        
        container.register(WithdrawGroupUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultWithdrawGroupUseCase(myGroupRepository: myGroupRepository)
        }.inObjectScope(.container)
        
        container.register(DeleteGroupUseCase.self) { r in
            let myGroupRepository = r.resolve(MyGroupRepository.self)!
            return DefaultDeleteGroupUseCase(myGroupRepository: myGroupRepository)
        }.inObjectScope(.container)
    }
    
}

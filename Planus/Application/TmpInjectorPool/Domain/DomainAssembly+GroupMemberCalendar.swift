//
//  DomainAssembly+GroupMemberCalendar.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {
    
    func assembleGroupMemberCalendar(container: Container) {
        container.register(FetchGroupMemberDailyCalendarUseCase.self) { r in
            let groupMemberCalendarRepository = r.resolve(GroupMemberCalendarRepository.self)!
            return DefaultFetchGroupMemberDailyCalendarUseCase(memberCalendarRepository: groupMemberCalendarRepository)
        }
        
        container.register(FetchGroupMemberCalendarUseCase.self) { r in
            let groupMemberCalendarRepository = r.resolve(GroupMemberCalendarRepository.self)!
            return DefaultFetchGroupMemberCalendarUseCase(memberCalendarRepository: groupMemberCalendarRepository)
        }
        
        container.register(FetchGroupMemberTodoDetailUseCase.self) { r in
            let groupMemberCalendarRepository = r.resolve(GroupMemberCalendarRepository.self)!
            return DefaultFetchGroupMemberTodoDetailUseCase(groupMemberCalendarRepository: groupMemberCalendarRepository)
        }
    }
    
}

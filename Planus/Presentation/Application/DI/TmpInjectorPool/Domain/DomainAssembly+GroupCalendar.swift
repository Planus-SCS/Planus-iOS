//
//  DomainAssembly+GroupCalendar.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {
    
    func assembleGroupCalendar(container: Container) {
        container.register(FetchGroupDailyCalendarUseCase.self) { r in
            let groupCalendarRepository = r.resolve(GroupCalendarRepository.self)!
            return DefaultFetchGroupDailyCalendarUseCase(groupCalendarRepository: groupCalendarRepository)
        }
        
        container.register(FetchGroupMonthlyCalendarUseCase.self) { r in
            let groupCalendarRepository = r.resolve(GroupCalendarRepository.self)!
            return DefaultFetchGroupMonthlyCalendarUseCase(groupCalendarRepository: groupCalendarRepository)
        }
        
        container.register(FetchGroupTodoDetailUseCase.self) { r in
            let groupCalendarRepository = r.resolve(GroupCalendarRepository.self)!
            return DefaultFetchGroupTodoDetailUseCase(groupCalendarRepository: groupCalendarRepository)
        }
        
        container.register(CreateGroupTodoUseCase.self) { r in
            let groupCalendarRepository = r.resolve(GroupCalendarRepository.self)!
            return DefaultCreateGroupTodoUseCase(groupCalendarRepository: groupCalendarRepository)
        }.inObjectScope(.container)
        
        container.register(UpdateGroupTodoUseCase.self) { r in
            let groupCalendarRepository = r.resolve(GroupCalendarRepository.self)!
            return DefaultUpdateGroupTodoUseCase(groupCalendarRepository: groupCalendarRepository)
        }.inObjectScope(.container)
        
        container.register(DeleteGroupTodoUseCase.self) { r in
            let groupCalendarRepository = r.resolve(GroupCalendarRepository.self)!
            return DefaultDeleteGroupTodoUseCase(groupCalendarRepository: groupCalendarRepository)
        }.inObjectScope(.container)
    }
    
}

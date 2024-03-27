//
//  SocialDailyCalendarAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class SocialDailyCalendarPresentationAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(SocialDailyCalendarViewModel.self) { (r, injectable: SocialDailyCalendarViewModel.Injectable) in
            return SocialDailyCalendarViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchGroupDailyTodoListUseCase: r.resolve(FetchGroupDailyCalendarUseCase.self)!,
                    fetchMemberDailyCalendarUseCase: r.resolve(FetchGroupMemberDailyCalendarUseCase.self)!,
                    createGroupTodoUseCase: r.resolve(CreateGroupTodoUseCase.self)!,
                    updateGroupTodoUseCase: r.resolve(UpdateGroupTodoUseCase.self)!,
                    deleteGroupTodoUseCase: r.resolve(DeleteGroupTodoUseCase.self)!,
                    updateGroupCategoryUseCase: r.resolve(UpdateGroupCategoryUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(SocialDailyCalendarViewController.self) { (r, injectable: SocialDailyCalendarViewModel.Injectable) in
            return SocialDailyCalendarViewController(viewModel: r.resolve(SocialDailyCalendarViewModel.self, argument: injectable)!)
        }
    }
    
}

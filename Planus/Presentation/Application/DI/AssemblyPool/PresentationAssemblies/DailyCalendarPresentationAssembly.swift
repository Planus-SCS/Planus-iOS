//
//  DailyCalendarAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class DailyCalendarPresentationAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(MyDailyCalendarViewModel.self) { (r, injectable: MyDailyCalendarViewModel.Injectable) in
            return MyDailyCalendarViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    createTodoUseCase: r.resolve(CreateTodoUseCase.self)!,
                    updateTodoUseCase: r.resolve(UpdateTodoUseCase.self)!,
                    deleteTodoUseCase: r.resolve(DeleteTodoUseCase.self)!,
                    todoCompleteUseCase: r.resolve(TodoCompleteUseCase.self)!,
                    createCategoryUseCase: r.resolve(CreateCategoryUseCase.self)!,
                    updateCategoryUseCase: r.resolve(UpdateCategoryUseCase.self)!,
                    deleteCategoryUseCase: r.resolve(DeleteCategoryUseCase.self)!,
                    readCategoryUseCase: r.resolve(ReadCategoryListUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(GroupDailyCalendarViewModel.self) { (r, injectable: GroupDailyCalendarViewModel.Injectable) in
            return GroupDailyCalendarViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchGroupDailyTodoListUseCase: r.resolve(FetchGroupDailyCalendarUseCase.self)!,
                    createGroupTodoUseCase: r.resolve(CreateGroupTodoUseCase.self)!,
                    updateGroupTodoUseCase: r.resolve(UpdateGroupTodoUseCase.self)!,
                    deleteGroupTodoUseCase: r.resolve(DeleteGroupTodoUseCase.self)!,
                    updateGroupCategoryUseCase: r.resolve(UpdateGroupCategoryUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(MemberDailyCalendarViewModel.self) { (r, injectable: MemberDailyCalendarViewModel.Injectable) in
            return MemberDailyCalendarViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchMemberDailyCalendarUseCase: r.resolve(FetchGroupMemberDailyCalendarUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
    }
}

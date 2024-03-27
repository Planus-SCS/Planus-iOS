//
//  HomeCalendarAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class HomeCalendarPresentationAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(HomeCalendarViewModel.self) { (r, injectable: HomeCalendarViewModel.Injectable) in
            return HomeCalendarViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    createTodoUseCase: r.resolve(CreateTodoUseCase.self)!,
                    readTodoListUseCase: r.resolve(ReadTodoListUseCase.self)!,
                    updateTodoUseCase: r.resolve(UpdateTodoUseCase.self)!,
                    deleteTodoUseCase: r.resolve(DeleteTodoUseCase.self)!,
                    todoCompleteUseCase: r.resolve(TodoCompleteUseCase.self)!,
                    createCategoryUseCase: r.resolve(CreateCategoryUseCase.self)!,
                    readCategoryListUseCase: r.resolve(ReadCategoryListUseCase.self)!,
                    updateCategoryUseCase: r.resolve(UpdateCategoryUseCase.self)!,
                    deleteCategoryUseCase: r.resolve(DeleteCategoryUseCase.self)!,
                    fetchGroupCategoryListUseCase: r.resolve(FetchAllGroupCategoryListUseCase.self)!,
                    fetchMyGroupNameListUseCase: r.resolve(FetchMyGroupNameListUseCase.self)!,
                    groupCreateUseCase: r.resolve(GroupCreateUseCase.self)!,
                    withdrawGroupUseCase: r.resolve(WithdrawGroupUseCase.self)!,
                    deleteGroupUseCase: r.resolve(DeleteGroupUseCase.self)!,
                    createMonthlyCalendarUseCase: r.resolve(CreateMonthlyCalendarUseCase.self)!,
                    dateFormatYYYYMMUseCase: r.resolve(DateFormatYYYYMMUseCase.self)!,
                    readProfileUseCase: r.resolve(ReadProfileUseCase.self)!,
                    updateProfileUseCase: r.resolve(UpdateProfileUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(HomeCalendarViewController.self) { (r, injectable: HomeCalendarViewModel.Injectable) in
            return HomeCalendarViewController(viewModel: r.resolve(HomeCalendarViewModel.self, argument: injectable)!)
        }
    }
}

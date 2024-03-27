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
        container.register(DailyCalendarViewModel.self) { (r, injectable: DailyCalendarViewModel.Injectable) in
            return DailyCalendarViewModel(
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
        
        container.register(DailyCalendarViewController.self) { (r, injectable: DailyCalendarViewModel.Injectable) in
            return DailyCalendarViewController(viewModel: r.resolve(DailyCalendarViewModel.self, argument: injectable)!)
        }
    }
}

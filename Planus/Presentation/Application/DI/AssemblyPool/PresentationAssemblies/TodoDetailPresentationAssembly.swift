//
//  TodoDetailAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class TodoDetailPresentationAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleTodoDetail(container: container)
        assembleCategorySelect(container: container)
        assembleCategoryDetail(container: container)
    }
}

extension TodoDetailPresentationAssembly {
    func assembleTodoDetail(container: Container) {
        container.register(MyTodoDetailViewModel.self) { (r, injectable: MyTodoDetailViewModel.Injectable) in
            return MyTodoDetailViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    createTodoUseCase: r.resolve(CreateTodoUseCase.self)!,
                    updateTodoUseCase: r.resolve(UpdateTodoUseCase.self)!,
                    deleteTodoUseCase: r.resolve(DeleteTodoUseCase.self)!,
                    readCategoryUseCase: r.resolve(ReadCategoryListUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(GroupTodoDetailViewModel.self) { (r, injectable: GroupTodoDetailViewModel.Injectable) in
            return GroupTodoDetailViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchGroupTodoDetailUseCase: r.resolve(FetchGroupTodoDetailUseCase.self)!,
                    createGroupTodoUseCase: r.resolve(CreateGroupTodoUseCase.self)!,
                    updateGroupTodoUseCase: r.resolve(UpdateGroupTodoUseCase.self)!,
                    deleteGroupTodoUseCase: r.resolve(DeleteGroupTodoUseCase.self)!,
                    fetchGroupCategorysUseCase: r.resolve(FetchGroupCategorysUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(MemberTodoDetailViewModel.self) { (r, injectable: MemberTodoDetailViewModel.Injectable) in
            return MemberTodoDetailViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchGroupMemberTodoDetailUseCase: r.resolve(FetchGroupMemberTodoDetailUseCase.self)!
                ),
                injectable: injectable
            )
        }
    }
    
    func assembleCategorySelect(container: Container) {
        container.register(MyCategorySelectViewModel.self) { (r, injectable: MyCategorySelectViewModel.Injectable) in
            return MyCategorySelectViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    deleteCategoryUseCase: r.resolve(DeleteCategoryUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(GroupCategorySelectViewModel.self) { (r, injectable: GroupCategorySelectViewModel.Injectable) in
            return GroupCategorySelectViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    deleteGroupCategoryUseCase: r.resolve(DeleteGroupCategoryUseCase.self)!
                ),
                injectable: injectable
            )
        }
    }
    
    func assembleCategoryDetail(container: Container) {
        container.register(MyCategoryDetailViewModel.self) { (r, injectable: MyCategoryDetailViewModel.Injectable) in
            return MyCategoryDetailViewModel(
                useCases: .init(
                    executeTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    createCategoryUseCase: r.resolve(CreateCategoryUseCase.self)!,
                    updateCategoryUseCase: r.resolve(UpdateCategoryUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(GroupCategoryDetailViewModel.self) { (r, injectable: GroupCategoryDetailViewModel.Injectable) in
                return GroupCategoryDetailViewModel(
                    useCases: .init(
                        executeTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                        createGroupCategoryUseCase: r.resolve(CreateGroupCategoryUseCase.self)!,
                        updateGroupCategoryUseCase: r.resolve(UpdateGroupCategoryUseCase.self)!
                    ),
                    injectable: injectable
                )
        }
    }
}

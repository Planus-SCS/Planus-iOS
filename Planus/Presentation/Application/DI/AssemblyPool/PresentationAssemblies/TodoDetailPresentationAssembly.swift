//
//  TodoDetailAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class TodoDetailPresentationAssembly: Assembly {
    enum TodoDetailPageType: String {
        case memberTodo = "MEMBER_TODO_DETAIL"
        case socialTodo = "SOCIAL_TODO_DETAIL"
    }
    
    func assemble(container: Container) {
        container.register(
            MemberTodoDetailViewModel.self
        ) { (r, injectable: MemberTodoDetailViewModel.Injectable) in
            return MemberTodoDetailViewModel(
                executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                createTodoUseCase: r.resolve(CreateTodoUseCase.self)!,
                updateTodoUseCase: r.resolve(UpdateTodoUseCase.self)!,
                deleteTodoUseCase: r.resolve(DeleteTodoUseCase.self)!,
                createCategoryUseCase: r.resolve(CreateCategoryUseCase.self)!,
                updateCategoryUseCase: r.resolve(UpdateCategoryUseCase.self)!,
                deleteCategoryUseCase: r.resolve(DeleteCategoryUseCase.self)!,
                readCategoryUseCase: r.resolve(ReadCategoryListUseCase.self)!,
                injectable: injectable
            )
        }
        
        container.register(SocialTodoDetailViewModel.self) { (r, injectable: SocialTodoDetailViewModel.Injectable) in
            return SocialTodoDetailViewModel(
                executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                fetchGroupMemberTodoDetailUseCase: r.resolve(FetchGroupMemberTodoDetailUseCase.self)!,
                fetchGroupTodoDetailUseCase: r.resolve(FetchGroupTodoDetailUseCase.self)!,
                createGroupTodoUseCase: r.resolve(CreateGroupTodoUseCase.self)!,
                updateGroupTodoUseCase: r.resolve(UpdateGroupTodoUseCase.self)!,
                deleteGroupTodoUseCase: r.resolve(DeleteGroupTodoUseCase.self)!,
                createGroupCategoryUseCase: r.resolve(CreateGroupCategoryUseCase.self)!,
                updateGroupCategoryUseCase: r.resolve(UpdateGroupCategoryUseCase.self)!,
                deleteGroupCategoryUseCase: r.resolve(DeleteGroupCategoryUseCase.self)!,
                fetchGroupCategorysUseCase: r.resolve(FetchGroupCategorysUseCase.self)!,
                injectable: injectable
            )
        }
        
        container.register(
            TodoDetailViewController.self,
            name: TodoDetailPageType.memberTodo.rawValue
        ) { (r, injectable: MemberTodoDetailViewModel.Injectable) in
            return TodoDetailViewController(viewModel: r.resolve(MemberTodoDetailViewModel.self, argument: injectable)!)
        }
        
        container.register(TodoDetailViewController.self, name: TodoDetailPageType.socialTodo.rawValue) { (r, injectable: SocialTodoDetailViewModel.Injectable) in
            return TodoDetailViewController(viewModel: r.resolve(SocialTodoDetailViewModel.self, argument: injectable)!)
        }
    }
}

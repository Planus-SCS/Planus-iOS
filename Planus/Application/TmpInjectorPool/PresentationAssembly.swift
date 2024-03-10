//
//  PresentationAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

class PresentationAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        assembleMyPageMain(container: container)
        assembleHomeCalendar(container: container)
        assembleDailyCalendar(container: container)
        assembleTodoDetail(container: container)
    }
    
}

import Swinject

extension PresentationAssembly {
    func assembleMyPageMain(container: Container) {
        container.register(MyPageMainViewModel.self) { (r, injectable: MyPageMainViewModel.Injectable) in
            return MyPageMainViewModel(
                useCases: .init(
                    updateProfileUseCase: r.resolve(UpdateProfileUseCase.self)!,
                    getTokenUseCase: r.resolve(GetTokenUseCase.self)!,
                    refreshTokenUseCase: r.resolve(RefreshTokenUseCase.self)!,
                    removeTokenUseCase: r.resolve(RemoveTokenUseCase.self)!,
                    removeProfileUseCase: r.resolve(RemoveProfileUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!,
                    getSignedInSNSTypeUseCase: r.resolve(GetSignedInSNSTypeUseCase.self)!,
                    convertToSha256UseCase: r.resolve(ConvertToSha256UseCase.self)!,
                    revokeAppleTokenUseCase: r.resolve(RevokeAppleTokenUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(MyPageMainViewController.self) { (r, profile: Profile) in
            return MyPageMainViewController(viewModel: r.resolve(MyPageMainViewModel.self, argument: profile)!)
        }
    }
    
    func assembleMyPageReadableViewModel(container: Container) {
        container.register(MyPageReadableViewModel.self) { (r, type: MyPageReadableType) in
            return MyPageReadableViewModel(type: type)
        }
        
        container.register(MyPageReadableViewController.self) { (r, type: MyPageReadableType) in
            return MyPageReadableViewController(viewModel: r.resolve(MyPageReadableViewModel.self, argument: type)!)
        }
    }
    
    func assembleMyPageEnquire(container: Container) {
        container.register(MyPageEnquireViewModel.self) { r in
            return MyPageEnquireViewModel()
        }
        
        container.register(MyPageEnquireViewController.self) { r in
            return MyPageEnquireViewController(viewModel: r.resolve(MyPageEnquireViewModel.self)!)
        }
    }
    
    func assembleMyPageEdit(container: Container) {
        container.register(MyPageEditViewModel.self) { r in
            return MyPageEditViewModel(
                getTokenUseCase: r.resolve(GetTokenUseCase.self)!,
                refreshTokenUseCase: r.resolve(RefreshTokenUseCase.self)!,
                readProfileUseCase: r.resolve(ReadProfileUseCase.self)!,
                updateProfileUseCase: r.resolve(UpdateProfileUseCase.self)!,
                fetchImageUseCase: r.resolve(FetchImageUseCase.self)!
            )
        }
        
        container.register(MyPageEditViewController.self) { r in
            return MyPageEditViewController(viewModel: r.resolve(MyPageEditViewModel.self)!)
        }
    }
    
}


extension PresentationAssembly {
    func assembleHomeCalendar(container: Container) {
        container.register(HomeCalendarViewModel.self) { (r, injectable: HomeCalendarViewModel.Injectable) in
            return HomeCalendarViewModel(
                useCases: .init(
                    getTokenUseCase: r.resolve(GetTokenUseCase.self)!,
                    refreshTokenUseCase: r.resolve(RefreshTokenUseCase.self)!,
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

extension PresentationAssembly {
    func assembleDailyCalendar(container: Container) {
        container.register(TodoDailyViewModel.self) { (r, injectable: TodoDailyViewModel.Injectable) in
            return TodoDailyViewModel(
                useCases: .init(
                    getTokenUseCase: r.resolve(GetTokenUseCase.self)!,
                    refreshTokenUseCase: r.resolve(RefreshTokenUseCase.self)!,
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
        
        container.register(TodoDailyViewController.self) { (r, injectable: TodoDailyViewModel.Injectable) in
            return TodoDailyViewController(viewModel: r.resolve(TodoDailyViewModel.self, argument: injectable)!)
        }
    }
}

extension PresentationAssembly {
    enum TodoDetailPageType: String {
        case memberTodo = "MEMBER_TODO_DETAIL"
        case socialTodo = "SOCIAL_TODO_DETAIL"
    }
    
    func assembleTodoDetail(container: Container) {
        container.register(
            MemberTodoDetailViewModel.self
        ) { (r, injectable: MemberTodoDetailViewModel.Injectable) in
            return MemberTodoDetailViewModel(
                getTokenUseCase: r.resolve(GetTokenUseCase.self)!,
                refreshTokenUseCase: r.resolve(RefreshTokenUseCase.self)!,
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
        
        container.register(
            TodoDetailViewController.self,
            name: TodoDetailPageType.memberTodo.rawValue
        ) { (r, injectable: MemberTodoDetailViewModel.Injectable) in
            let vm = r.resolve(MemberTodoDetailViewModel.self, argument: injectable)!
            return TodoDetailViewController(viewModel: vm)
        }
    }
}

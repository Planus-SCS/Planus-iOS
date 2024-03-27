//
//  MyGroupDetailAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class MyGroupDetailPresentationAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleMyGroupDetail(container: container)
        assembleMyGroupInfoEdit(container: container)
        assembleMyGroupMemberEdit(container: container)
        assembleMyGroupNoticeEdit(container: container)
    }
    
    func assembleMyGroupDetail(container: Container) {
        container.register(MyGroupDetailViewModel.self) { (r, injectable: MyGroupDetailViewModel.Injectable) in
            return MyGroupDetailViewModel(
                useCases: .init(
                    fetchMyGroupDetailUseCase: r.resolve(FetchMyGroupDetailUseCase.self)!,
                    updateNoticeUseCase: r.resolve(UpdateNoticeUseCase.self)!,
                    updateInfoUseCase: r.resolve(UpdateGroupInfoUseCase.self)!,
                    withdrawGroupUseCase: r.resolve(WithdrawGroupUseCase.self)!,
                    fetchMyGroupMemberListUseCase: r.resolve(FetchMyGroupMemberListUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!,
                    memberKickOutUseCase: r.resolve(MemberKickOutUseCase.self)!,
                    setOnlineUseCase: r.resolve(SetOnlineUseCase.self)!,
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    createMonthlyCalendarUseCase: r.resolve(CreateMonthlyCalendarUseCase.self)!,
                    fetchMyGroupCalendarUseCase: r.resolve(FetchGroupMonthlyCalendarUseCase.self)!,
                    createGroupTodoUseCase: r.resolve(CreateGroupTodoUseCase.self)!,
                    updateGroupTodoUseCase: r.resolve(UpdateGroupTodoUseCase.self)!,
                    deleteGroupTodoUseCase: r.resolve(DeleteGroupTodoUseCase.self)!,
                    updateGroupCategoryUseCase: r.resolve(UpdateGroupCategoryUseCase.self)!,
                    generateGroupLinkUseCase: r.resolve(GenerateGroupLinkUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(MyGroupDetailViewController.self) { (r, injectable: MyGroupDetailViewModel.Injectable) in
            return MyGroupDetailViewController(viewModel: r.resolve(MyGroupDetailViewModel.self, argument: injectable)!)
        }
    }
    
    func assembleMyGroupInfoEdit(container: Container) {
        container.register(MyGroupInfoEditViewModel.self) { (r, injectable: MyGroupInfoEditViewModel.Injectable) in
            return MyGroupInfoEditViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!,
                    updateGroupInfoUseCase: r.resolve(UpdateGroupInfoUseCase.self)!,
                    deleteGroupUseCase: r.resolve(DeleteGroupUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(MyGroupInfoEditViewController.self) { (r, injectable: MyGroupInfoEditViewModel.Injectable) in
            return MyGroupInfoEditViewController(viewModel: r.resolve(MyGroupInfoEditViewModel.self, argument: injectable)!)
        }
    }
    
    func assembleMyGroupMemberEdit(container: Container) {
        container.register(MyGroupMemberEditViewModel.self) { (r, injectable: MyGroupMemberEditViewModel.Injectable) in
            return MyGroupMemberEditViewModel(
                useCase: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchMyGroupMemberListUseCase: r.resolve(FetchMyGroupMemberListUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!,
                    memberKickOutUseCase: r.resolve(MemberKickOutUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(MyGroupMemberEditViewController.self) { (r, injectable: MyGroupMemberEditViewModel.Injectable) in
            return MyGroupMemberEditViewController(viewModel: r.resolve(MyGroupMemberEditViewModel.self, argument: injectable)!)
        }
    }
    
    func assembleMyGroupNoticeEdit(container: Container) {
        container.register(MyGroupNoticeEditViewModel.self) { (r, injectable: MyGroupNoticeEditViewModel.Injectable) in
            return MyGroupNoticeEditViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    updateNoticeUseCase: r.resolve(UpdateNoticeUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(MyGroupNoticeEditViewController.self) { (r, injectable: MyGroupNoticeEditViewModel.Injectable) in
            return MyGroupNoticeEditViewController(viewModel: r.resolve(MyGroupNoticeEditViewModel.self, argument: injectable)!)
        }
    }
    
}

//
//  GroupCreateAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class GroupCreatePresentationAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleGroupCreate(container: container)
        assembleGroupCreateLoading(container: container)
    }
    
    func assembleGroupCreate(container: Container) {
        container.register(GroupCreateViewModel.self) { (r, injectable: GroupCreateViewModel.Injectable) in
            return GroupCreateViewModel(
                useCases: .init(
                    getTokenUseCase: r.resolve(GetTokenUseCase.self)!,
                    refreshTokenUseCase: r.resolve(RefreshTokenUseCase.self)!,
                    groupCreateUseCase: r.resolve(GroupCreateUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(GroupCreateViewController.self) { (r, injectable: GroupCreateViewModel.Injectable) in
            return GroupCreateViewController(viewModel: r.resolve(GroupCreateViewModel.self, argument: injectable)!)
        }
    }
    
    func assembleGroupCreateLoading(container: Container) {
        container.register(GroupCreateLoadViewModel.self) { (r, injectable: GroupCreateLoadViewModel.Injectable) in
            return GroupCreateLoadViewModel(
                useCases: .init(
                    getTokenUseCase: r.resolve(GetTokenUseCase.self)!,
                    refreshTokenUseCase: r.resolve(RefreshTokenUseCase.self)!,
                    groupCreateUseCase: r.resolve(GroupCreateUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(GroupCreateLoadViewController.self) { (r, injectable: GroupCreateLoadViewModel.Injectable) in
            return GroupCreateLoadViewController(viewModel: r.resolve(GroupCreateLoadViewModel.self, argument: injectable)!)
        }
    }
    
}

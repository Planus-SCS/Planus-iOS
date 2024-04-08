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
                    groupCreateUseCase: r.resolve(GroupCreateUseCase.self)!
                ),
                injectable: injectable
            )
        }
    }
    
    func assembleGroupCreateLoading(container: Container) {
        container.register(GroupCreateLoadViewModel.self) { (r, injectable: GroupCreateLoadViewModel.Injectable) in
            return GroupCreateLoadViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    groupCreateUseCase: r.resolve(GroupCreateUseCase.self)!
                ),
                injectable: injectable
            )
        }
    }
    
}

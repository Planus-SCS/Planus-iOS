//
//  GroupIntroduceAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class GroupIntroducePresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(GroupIntroduceViewModel.self) { (r, injectable: GroupIntroduceViewModel.Injectable) in
            return GroupIntroduceViewModel(
                useCases: .init(
                    getTokenUseCase: r.resolve(GetTokenUseCase.self)!,
                    refreshTokenUseCase: r.resolve(RefreshTokenUseCase.self)!,
                    setTokenUseCase: r.resolve(SetTokenUseCase.self)!,
                    fetchUnJoinedGroupUseCase: r.resolve(FetchUnJoinedGroupUseCase.self)!,
                    fetchMemberListUseCase: r.resolve(FetchMemberListUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!,
                    applyGroupJoinUseCase: r.resolve(ApplyGroupJoinUseCase.self)!,
                    generateGroupLinkUseCase: r.resolve(GenerateGroupLinkUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(GroupIntroduceViewController.self) { (r, injectable: GroupIntroduceViewModel.Injectable) in
            return GroupIntroduceViewController(viewModel: r.resolve(GroupIntroduceViewModel.self, argument: injectable)!)
        }
    }
}

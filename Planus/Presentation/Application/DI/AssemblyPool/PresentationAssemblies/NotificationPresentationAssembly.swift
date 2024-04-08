//
//  NotificationAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class NotificationPresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NotificationViewModel.self) { (r, injectable: NotificationViewModel.Injectable) in
            return NotificationViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    setTokenUseCase: r.resolve(SetTokenUseCase.self)!,
                    fetchJoinApplyListUseCase: r.resolve(FetchJoinApplyListUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!,
                    acceptGroupJoinUseCase: r.resolve(AcceptGroupJoinUseCase.self)!,
                    denyGroupJoinUseCase: r.resolve(DenyGroupJoinUseCase.self)!
                ),
                injectable: injectable
            )
        }
    }
}

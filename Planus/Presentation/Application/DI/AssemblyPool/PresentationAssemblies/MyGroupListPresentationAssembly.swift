//
//  MyGroupListAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class MyGroupListPresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MyGroupListViewModel.self) { (r, injectable: MyGroupListViewModel.Injectable) in
            return MyGroupListViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchMyGroupListUseCase: r.resolve(FetchMyGroupListUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!,
                    groupCreateUseCase: r.resolve(GroupCreateUseCase.self)!,
                    setOnlineUseCase: r.resolve(SetOnlineUseCase.self)!,
                    updateGroupInfoUseCase: r.resolve(UpdateGroupInfoUseCase.self)!,
                    withdrawGroupUseCase: r.resolve(WithdrawGroupUseCase.self)!,
                    deleteGroupUseCase: r.resolve(DeleteGroupUseCase.self)!
                ),
                injectable: injectable
            )
        }
    }
}

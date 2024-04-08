//
//  MyPageAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class MyPagePresentationAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        assembleMyPageMain(container: container)
        assembleMyPageReadableViewModel(container: container)
        assembleMyPageEdit(container: container)
    }
    
    func assembleMyPageMain(container: Container) {
        container.register(MyPageMainViewModel.self) { (r, injectable: MyPageMainViewModel.Injectable) in
            return MyPageMainViewModel(
                useCases: .init(
                    updateProfileUseCase: r.resolve(UpdateProfileUseCase.self)!,
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
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
    }
    
    func assembleMyPageReadableViewModel(container: Container) {
        container.register(MyPageReadableViewModel.self) { (r, injectable: MyPageReadableViewModel.Injectable) in
            return MyPageReadableViewModel(
                useCases: .init(),
                injectable: injectable
            )
        }
    }
    
    func assembleMyPageEdit(container: Container) {
        container.register(MyPageEditViewModel.self) { (r, injectable: MyPageEditViewModel.Injectable) in
            return MyPageEditViewModel(
                useCases: .init(
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    readProfileUseCase: r.resolve(ReadProfileUseCase.self)!,
                    updateProfileUseCase: r.resolve(UpdateProfileUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!
                ),
                injectable: injectable
            )
        }
    }
    
}

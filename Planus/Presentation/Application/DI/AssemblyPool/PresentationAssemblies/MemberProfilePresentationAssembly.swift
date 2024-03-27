//
//  MemberProfileAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/21/24.
//

import Foundation
import Swinject

class MemberProfilePresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MemberProfileViewModel.self) { (r, injectable: MemberProfileViewModel.Injectable) in
            return MemberProfileViewModel(
                useCases: .init(
                    createMonthlyCalendarUseCase: r.resolve(CreateMonthlyCalendarUseCase.self)!,
                    dateFormatYYYYMMUseCase: r.resolve(DateFormatYYYYMMUseCase.self)!,
                    executeWithTokenUseCase: r.resolve(ExecuteWithTokenUseCase.self)!,
                    fetchMemberCalendarUseCase: r.resolve(FetchGroupMemberCalendarUseCase.self)!,
                    fetchImageUseCase: r.resolve(FetchImageUseCase.self)!
                ),
                injectable: injectable
            )
        }
        
        container.register(MemberProfileViewController.self) { (r, injectable: MemberProfileViewModel.Injectable) in
            return MemberProfileViewController(viewModel: r.resolve(MemberProfileViewModel.self, argument: injectable)!)
        }
    }
}

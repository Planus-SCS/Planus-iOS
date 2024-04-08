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
        let assemblies: [Assembly] = [
            MyPagePresentationAssembly(),
            HomeCalendarPresentationAssembly(),
            DailyCalendarPresentationAssembly(),
            TodoDetailPresentationAssembly(),
            SignInPresentationAssembly(),
            SearchPresentationAssembly(),
            GroupCreatePresentationAssembly(),
            GroupIntroducePresentationAssembly(),
            NotificationPresentationAssembly(),
            MyGroupListPresentationAssembly(),
            MyGroupDetailPresentationAssembly(),
            MemberProfilePresentationAssembly()
        ]
            
        assemblies.forEach {
            $0.assemble(container: container)
        }
    }
    
}

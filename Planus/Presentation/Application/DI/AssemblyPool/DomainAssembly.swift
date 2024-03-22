//
//  DomainAssembly.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

class DomainAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        let assemblies: [Assembly] = [
            GroupMemberCalendarDomainAssembly(),
            GroupCategoryDomainAssembly(),
            GroupCalendarDomainAssembly(),
            GroupDomainAssembly(),
            MyGroupDomainAssembly(),
            ImageDomainAssembly(),
            ProfileDomainAssembly(),
            SignInDomainAssembly(),
            CalendarDomainAssembly(),
            TodoDomainAssembly(),
            CategoryDomainAssembly(),
            TokenDomainAssembly()
        ]
        
        assemblies.forEach {
            $0.assemble(container: container)
        }
    }
}



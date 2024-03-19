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
        assembleTodo(container: container)
        assembleGroup(container: container)
        assembleImage(container: container)
        assembleToken(container: container)
        assembleProfile(container: container)
        assembleCalendar(container: container)
        assembleCategory(container: container)
        assembleSignIn(container: container)
        assembleMyGroup(container: container)
        assembleGroupCalendar(container: container)
        assembleGroupCategory(container: container)
        assembleGroupMemberCalendar(container: container)
    }
}



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
        assembleGroupMemberCalendar(container: container)
    }
}



//
//  DomainAssembly+Calendar.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

class CalendarDomainAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(CreateMonthlyCalendarUseCase.self) { _ in
            return DefaultCreateMonthlyCalendarUseCase()
        }
        
        container.register(DateFormatYYYYMMUseCase.self) { _ in
            return DefaultDateFormatYYYYMMUseCase()
        }
        
    }
    
}

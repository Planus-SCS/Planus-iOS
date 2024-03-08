//
//  DomainAssembly+Calendar.swift
//  Planus
//
//  Created by Sangmin Lee on 3/9/24.
//

import Foundation
import Swinject

extension DomainAssembly {
    
    func assembleCalendar(container: Container) {
        container.register(CreateMonthlyCalendarUseCase.self) { _ in
            return DefaultCreateMonthlyCalendarUseCase()
        }
        
        container.register(DateFormatYYYYMMUseCase.self) { _ in
            return DefaultDateFormatYYYYMMUseCase()
        }
        
        container.register(CreateDailyCalendarUseCase.self) { _ in
            return DefaultCreateDailyCalendarUseCase()
        }
    }
    
}

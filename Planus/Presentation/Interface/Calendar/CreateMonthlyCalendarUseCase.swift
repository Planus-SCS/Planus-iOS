//
//  CreateMonthlyCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation

protocol CreateMonthlyCalendarUseCase {
    func execute(date: Date) -> [DayViewModel]
}

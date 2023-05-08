//
//  CreateDailyCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import Foundation

protocol CreateDailyCalendarUseCase {
    func execute(from: Date, to: Date) -> [DetailDayViewModel]
}

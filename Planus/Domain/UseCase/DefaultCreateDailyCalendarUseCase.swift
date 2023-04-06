//
//  DefaultCreateDailyCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import Foundation

class DefaultCreateDailyCalendarUseCase: CreateDailyCalendarUseCase {
    func execute(from: Date, to: Date) -> [DetailDayViewModel] {
        let diff = Calendar.current.dateComponents([.day], from: from, to: to).day ?? Int()
        return (0..<diff).map {
            let date = Calendar.current.date(byAdding: DateComponents(day: $0), to: from) ?? Date()
            return DetailDayViewModel(date: date, scheduledTodoList: [], unSchedultedTodoList: [])
        }
    }
}

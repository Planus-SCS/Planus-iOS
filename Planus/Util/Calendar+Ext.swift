//
//  Calendar+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation

extension Calendar {
    func startDayOfTheWeek(from calendarDate: Date) -> Int {
        return self.component(.weekday, from: calendarDate) - 1
    }
    
    func endDateOfMonth(for calendarDate: Date) -> Int {
        return self.range(of: .day, in: .month, for: calendarDate)?.count ?? Int()
    }
    
    func startDayOfMonth(date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month], from: self.startOfDay(for: date))) ?? Date()
    }
}

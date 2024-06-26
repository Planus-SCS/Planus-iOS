//
//  Calendar+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation

extension Calendar {
    func startOfDay(date: Date) -> Date {
        let components = self.dateComponents(
            [.year, .month, .day],
            from: date
        )
        return self.date(from: components)!
    }
    
    func startDayOfTheWeek(from calendarDate: Date) -> Int {
        return self.component(.weekday, from: calendarDate) - 1
    }
    
    func endDateOfMonth(for calendarDate: Date) -> Int {
        return self.range(of: .day, in: .month, for: calendarDate)?.count ?? Int()
    }
    
    func endDateOfTheWeek(from date: Date) -> Date {
        let firstDayOfWeek = self.date(from: self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))
        return self.date(byAdding: .day, value: 6, to: firstDayOfWeek!)!
    }
    
    func startDayOfMonth(date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month], from: self.startOfDay(for: date))) ?? Date()
    }
    
    
    func innSameWeek(_ date1: Date, _ date2: Date) -> Bool {
        let weekOfYear1 = self.component(.weekOfYear, from: date1)
        let weekOfYear2 = self.component(.weekOfYear, from: date2)
        
        return weekOfYear1 == weekOfYear2
    }

}

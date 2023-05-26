//
//  DefaultCreateSocialMonthlyCalendarUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation

class DefaultCreateSocialMonthlyCalendarUseCase: CreateSocialMonthlyCalendarUseCase {
    var calendar: Calendar
    
    init() {
        self.calendar = Calendar.current
    }
    
    func execute(date: Date) -> [SocialDayViewModel] {
        
        let currentMonthStartIndex = (calendar.startDayOfTheWeek(from: date) + 7 - 1)%7
        let followingMonthStartIndex = currentMonthStartIndex + calendar.endDateOfMonth(for: date)
        let totalDaysCount = followingMonthStartIndex + ((followingMonthStartIndex % 7 == 0) ? 0 : (7 - followingMonthStartIndex % 7))
        var currentMonthStartDate = calendar.startDayOfMonth(date: date)
        
        var dayList = [SocialDayViewModel]()
        
        (0..<totalDaysCount).forEach { day in
            var date: Date
            var state: MonthStateOfDay
            switch day {
            case (0..<currentMonthStartIndex):
                date = calendar.date(byAdding: DateComponents(day: -currentMonthStartIndex + day), to: currentMonthStartDate) ?? Date()
                state = .prev
            case (currentMonthStartIndex..<followingMonthStartIndex):
                date = calendar.date(byAdding: DateComponents(day: day - currentMonthStartIndex), to: currentMonthStartDate) ?? Date()
                state = .current
            case (followingMonthStartIndex..<totalDaysCount):
                date = calendar.date(byAdding: DateComponents(day: day - currentMonthStartIndex), to: currentMonthStartDate) ?? Date()
                state = .following
            default:
                fatalError()
            }
            
            dayList.append(SocialDayViewModel(
                date: date,
                dayString: "\(calendar.component(.day, from: date))",
                weekDay: WeekDay(rawValue: day%7)!,
                state: state,
                todoList: []
            ))
        }
        
        return dayList
    }
}

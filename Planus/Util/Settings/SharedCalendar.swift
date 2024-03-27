//
//  SharedCalendar.swift
//  Planus
//
//  Created by Sangmin Lee on 3/25/24.
//

import Foundation

public let sharedCalendar: Calendar = {
    var calendar = Calendar.current
    calendar.firstWeekday = 2
    return calendar
}()

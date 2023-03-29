//
//  DayPickerModel.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import Foundation

enum DayPickerModelRangeState {
    case only
    case start
    case end
    case inRange
    case none
}

struct DayPickerModel {
    var dayLabel: String
    var date: Date
    var monthState: MonthStateOfDay
    var rangeState: DayPickerModelRangeState
}

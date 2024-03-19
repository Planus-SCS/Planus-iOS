//
//  Day.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation

struct Day {
    var date: Date //캐시의 To-Do 탐색 용
    var weekDay: WeekDay
    var state: MonthStateOfDay //흐리게 or 진하게 표시용
}

//
//  Day.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation

struct DayViewModel {
    var date: Date //캐시의 To-Do 탐색 용
    var dayString: String //셀 위에 표시 용
    var weekDay: WeekDay
    var state: MonthStateOfDay //흐리게 or 진하게 표시용
    var todo: [Todo] //To-do 나열 용
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(state)
    }
}

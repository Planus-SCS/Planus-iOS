//
//  TodoType.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/22.
//

import Foundation

enum TodoType {
    case repeated(WeekDay)
    case continuous(ContinuousDays)
    case normal
}

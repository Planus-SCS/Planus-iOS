//
//  DateRange.swift
//  Planus
//
//  Created by Sangmin Lee on 4/6/24.
//

import Foundation

struct DateRange: Equatable {
    var start: Date?
    var end: Date?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}

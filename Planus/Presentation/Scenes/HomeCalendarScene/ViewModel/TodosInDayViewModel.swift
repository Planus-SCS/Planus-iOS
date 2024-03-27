//
//  DailyViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 3/23/24.
//

import Foundation

struct DailyViewModel {
    var periodTodo: [(Int, TodoSummaryViewModel)] //offset, Todo
    var singleTodo: [(Int,TodoSummaryViewModel)] //offset, Todo
    var holiday: (Int, String)?
}

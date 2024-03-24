//
//  TodosInDayViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 3/23/24.
//

import Foundation

struct TodosInDayViewModel {
    var periodTodo: [(Int,Todo)] //offset, Todo
    var singleTodo: [(Int,Todo)] //offset, Todo
    var holiday: (Int, String)?
}

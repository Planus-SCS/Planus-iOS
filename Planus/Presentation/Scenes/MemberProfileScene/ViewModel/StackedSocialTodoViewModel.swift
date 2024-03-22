//
//  StackedSocialTodoViewModel.swift
//  Planus
//
//  Created by Sangmin Lee on 3/23/24.
//

import Foundation

struct FilteredSocialTodoViewModel {
    var periodTodo: [(Int, SocialTodoSummary)] //offset, Todo
    var singleTodo: [(Int, SocialTodoSummary)] //offset, Todo
    var holiday: (Int, String)?
}

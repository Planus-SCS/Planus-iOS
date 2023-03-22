//
//  FetchTodoListUseCase.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/23.
//

import Foundation

protocol FetchTodoListUseCase {
    func execute(date: Date) -> [Todo]
}

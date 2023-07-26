//
//  GroupCalendarRepository.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/26.
//

import Foundation
import RxSwift

protocol GroupCalendarRepository {
    func fetchMonthlyCalendar(token: String, groupId: Int, from: Date, to: Date) -> Single<ResponseDTO<[SocialTodoSummaryResponseDTO]>>
    func fetchDailyCalendar(token: String, groupId: Int, date: Date) -> Single<ResponseDTO<SocialTodoDailyListResponseDTO>>
    func fetchTodoDetail(token: String, groupId: Int, todoId: Int) -> Single<ResponseDTO<SocialTodoDetailResponseDTO>>
    func createTodo(token: String, groupId: Int, todo: TodoRequestDTO) -> Single<Int>
    func updateTodo(token: String, groupId: Int, todoId: Int, todo: TodoRequestDTO) -> Single<Int>
    func deleteTodo(token: String, groupId: Int, todoId: Int) -> Single<Void>
}

//
//  DayViewModel.swift
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
    var todoList: [Todo]
}

struct SocialDayViewModel {
    var date: Date //캐시의 To-Do 탐색 용
    var dayString: String //셀 위에 표시 용
    var weekDay: WeekDay
    var state: MonthStateOfDay //흐리게 or 진하게 표시용
    var todoList: [SocialTodoSummary]
}

/*
 todo는 필요할때마다 받아와야하는가? 이게맞나??? 달력안에 투두를 갖고있는건 좀 이상한가??????????????????? 뷰모델안에 저장해놓을 필요도 없는건가????????????
 아니지 이건 Day가 아니라 DayViewModel을 만들어야하는거같은데?????????????? 그게 맞지 않나??????? 셀안에 표시할 모든 정보를 담기위한 뷰모델이 따로 필요할듯???
 ex: Day랑 todo를 갖는 뷰모델????
 */

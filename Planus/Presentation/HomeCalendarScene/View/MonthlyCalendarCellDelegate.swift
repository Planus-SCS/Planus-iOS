//
//  MonthlyCalendarCellDelegate.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit

// 내부의 콜렉션뷰를 위해 델리게이트로 뷰컨쪽에서 정보 받아오기
protocol MonthlyCalendarCellDelegate: NSObject {
    func monthlyCalendarCell(_ monthlyCalendarCell: MonthlyCalendarCell, at indexPath: IndexPath) -> DayViewModel?
    func monthlyCalendarCell(_ monthlyCalendarCell: MonthlyCalendarCell, maxCountOfTodoInWeek indexPath: IndexPath) -> DayViewModel?
    func numberOfItems(_ monthlyCalendarCell: MonthlyCalendarCell, in section: Int) -> Int?
    func findCachedHeight(_ monthlyCalendarCell: MonthlyCalendarCell, todoCount: Int) -> Double?
    func cacheHeight(_ monthlyCalendarCell: MonthlyCalendarCell, count: Int, height: Double)
    func frameWidth(_ monthlyCalendarCell: MonthlyCalendarCell) -> CGSize
}

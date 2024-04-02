//
//  MonthlyCalendarCellDelegate.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit

protocol MonthlyCalendarCellDelegate: NSObject {
    func monthlyCalendarCell(_ monthlyCalendarCell: MonthlyCalendarCell, at indexPath: IndexPath) -> Day?
    func monthlyCalendarCell(_ monthlyCalendarCell: MonthlyCalendarCell, maxCountOfTodoInWeek indexPath: IndexPath) -> Day?
    func numberOfItems(_ monthlyCalendarCell: MonthlyCalendarCell, in section: Int) -> Int?
    func findCachedHeight(_ monthlyCalendarCell: MonthlyCalendarCell, todoCount: Int) -> Double?
    func cacheHeight(_ monthlyCalendarCell: MonthlyCalendarCell, count: Int, height: Double)
    func frameWidth(_ monthlyCalendarCell: MonthlyCalendarCell) -> CGSize
    func colorOf(_ monthlyCalendarCell: MonthlyCalendarCell, colorOfCategoryId: Int) -> CategoryColor?
}

//
//  TodoDetailVC+DayPickerDelegate.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/25.
//

import UIKit

extension TodoDetailViewController: DayPickerViewControllerDelegate {
    func dayPickerViewController(_ dayPickerViewController: DayPickerViewController, didSelectDate: Date) {
        todoDetailView.dateView.setDate(startDate: dayPickerViewController.dateFormatter2.string(from: didSelectDate))
        didSelectedDateRange.accept(DateRange(start: didSelectDate))
    }
    
    func unHighlightAllItem(_ dayPickerViewController: DayPickerViewController) {
        todoDetailView.dateView.setDate()
        didSelectedDateRange.accept(DateRange())
    }
    
    func dayPickerViewController(_ dayPickerViewController: DayPickerViewController, didSelectDateInRange: (Date, Date)) {
        let (a, b) = didSelectDateInRange
        
        let min = min(a, b)
        let max = max(a, b)
        todoDetailView.dateView.setDate(
            startDate: dayPickerViewController.dateFormatter2.string(from: min),
            endDate: dayPickerViewController.dateFormatter2.string(from: max)
        )

        didSelectedDateRange.accept(DateRange(start: min, end: max))
    }
}

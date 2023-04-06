//
//  DayPickerViewControllerDelegate.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import Foundation

protocol DayPickerViewControllerDelegate {
    func unHighlightAllItem(_ dayPickerViewController: DayPickerViewController)
    func dayPickerViewController(_ dayPickerViewController: DayPickerViewController, didSelectDate: Date)
    func dayPickerViewController(_ dayPickerViewController: DayPickerViewController, didSelectDateInRange: (Date, Date))
}

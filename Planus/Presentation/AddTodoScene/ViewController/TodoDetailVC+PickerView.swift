//
//  TodoDetailVC+PickerView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/25.
//

import UIKit

extension TodoDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel?.groups.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel?.groups[row].groupName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelectedGroupAt.onNext(row)
    }
}

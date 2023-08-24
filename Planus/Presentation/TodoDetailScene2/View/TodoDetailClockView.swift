//
//  TodoDetailClockView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/23.
//

import UIKit

class TodoDetailClockView: UIView, TodoDetailAttributeView {
    var bottomConstraint: NSLayoutConstraint!
    
    var timePicker: UIDatePicker = {
        let picker = UIDatePicker(frame: .zero)
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .time
        picker.locale = Locale(identifier: "ko_KR")
        return picker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(timePicker)
    }
    
    func configureLayout() {
        timePicker.snp.makeConstraints {
            $0.height.equalTo(80)
            $0.width.equalTo(250)
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(10)
        }
    }
}

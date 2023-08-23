//
//  TodoDetailGroupView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/23.
//

import UIKit

class TodoDetailGroupView: UIView {
    lazy var groupPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.selectRow(30, inComponent: 0, animated: true)
        self.addSubview(picker)
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
        self.addSubview(groupPickerView)
    }
    
    func configureLayout() {
        groupPickerView.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(20)
        }
    }
}

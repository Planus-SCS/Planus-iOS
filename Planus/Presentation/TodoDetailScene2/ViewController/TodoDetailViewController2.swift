//
//  TodoDetailViewController2.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/23.
//

import UIKit
import RxSwift

class TodoDetailViewController2: UIViewController {
    var bag = DisposeBag()
    var scrollView = UIScrollView(frame: .zero)
    var contentStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    var titleView = TodoDetailTitleView(frame: .zero)
    var dateView = TodoDetailDateView(frame: .zero)
    var groupView = TodoDetailGroupView(frame: .zero)
    var memoView = TodoDetailMemoView(frame: .zero)
    var icnView = TodoDetailIcnView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
        titleView.backgroundColor = .white
        configureView()
        configureLayout()
        
    }
    
    func configureData() {
        groupView.groupPickerView.dataSource = self
        groupView.groupPickerView.delegate = self
    }
    
    // 스택뷰를 쓸것인가??? 애네는 일단 그냥 뷰에 담ㅈ
    func configureView() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        contentStackView.backgroundColor = .white
        
        contentStackView.addArrangedSubview(titleView)
        contentStackView.addArrangedSubview(dateView)
        contentStackView.addArrangedSubview(groupView)
        contentStackView.addArrangedSubview(memoView)
        contentStackView.addArrangedSubview(icnView)
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        contentStackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
    }
    
}

extension TodoDetailViewController2: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "그룹 선택"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row)
    }
    
}

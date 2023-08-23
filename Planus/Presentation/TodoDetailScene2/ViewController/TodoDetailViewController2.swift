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
    var titleView = TodoDetailTitleView(frame: .zero)
    var a = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
        titleView.backgroundColor = .white
        configureView()
        configureLayout()
        
    }
    
    // 스택뷰를 쓸것인가??? 애네는 일단 그냥 뷰에 담ㅈ
    func configureView() {
        self.view.addSubview(titleView)
    }
    
    func configureLayout() {
        titleView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
}

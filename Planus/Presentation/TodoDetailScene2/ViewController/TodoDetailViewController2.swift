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
    
    var contentStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    var titleView = TodoDetailTitleView(frame: .zero)
    
    var icnView = TodoDetailIcnView(frame: .zero)

    
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
        contentStackView.backgroundColor = .white
        
        self.view.addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleView)
        contentStackView.addArrangedSubview(icnView)
    }
    
    func configureLayout() {
        contentStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
}

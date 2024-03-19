//
//  JoinedGroupChattingViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit

class JoinedGroupChattingViewController: NestedScrollableViewController {
    var emptyResultView: EmptyResultView = {
        let view = EmptyResultView(text: "🚧 개발중 👷‍♂️")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(emptyResultView)
        emptyResultView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

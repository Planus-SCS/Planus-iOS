//
//  MyPageMainHeaderView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import UIKit

class MyPageMainHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "my-page-main-header-view"
    
    var memberProfileHeaderView = MemberProfileHeaderView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(memberProfileHeaderView)
    }
    
    func configureLayout() {
        memberProfileHeaderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}

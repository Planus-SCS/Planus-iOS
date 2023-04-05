//
//  MyGroupNoticeEditViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit

class MyGroupNoticeEditViewController: UIViewController {
    var noticeTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.layer.cornerRadius = 10
        textView.layer.cornerCurve = .continuous
        textView.font = UIFont(name: "Pretendard-Regular", size: 16)
        return textView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.view.addSubview(noticeTextView)
    }
    
    func configureLayout() {
        noticeTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(26)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(300)
        }
    }
}

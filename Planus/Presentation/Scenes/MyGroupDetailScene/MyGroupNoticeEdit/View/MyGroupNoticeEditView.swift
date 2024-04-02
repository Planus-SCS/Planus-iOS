//
//  MyGroupNoticeView.swift
//  Planus
//
//  Created by Sangmin Lee on 3/26/24.
//

import UIKit
import RxSwift

final class MyGroupNoticeEditView: UIView {
    lazy var noticeTextView: PlaceholderTextView = {
        let textView = PlaceholderTextView(frame: .zero)
        textView.layer.cornerRadius = 10
        textView.layer.cornerCurve = .continuous
        textView.font = UIFont(name: "Pretendard-Regular", size: 16)
        textView.placeholder = "간단한 그룹소개 및 공지사항을 입력해주세요"
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10

        let attributedString = NSMutableAttributedString(string: textView.text)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: attributedString.length))

        textView.attributedText = attributedString
        return textView
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .planusBlack
        return item
    }()
    
    lazy var saveButton: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "saveBarBtn"), style: .plain, target: nil, action: nil)
        item.tintColor = .planusTintBlue
        return item
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MyGroupNoticeEditView {
    func configureView() {
        self.backgroundColor = .planusBackgroundColor
        self.addSubview(noticeTextView)
    }
    
    func configureLayout() {
        noticeTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(26)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-300)
        }
    }
}

//
//  GroupIntroduceNoticeCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupIntroduceNoticeCell: UICollectionViewCell {
    static let reuseIdentifier = "group-introduce-notice-cell"

    var noticeTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont(name: "Pretendard-Regular", size: 16)
        textView.textColor = .black
        textView.textAlignment = NSTextAlignment.left
//        textView.dataDetectorTypes = UIDataDetectorTypes.all
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor(hex: 0xF5F5FB)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 19

        let attributedString = NSMutableAttributedString(string: textView.text)

        // 자간 조절 설정
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(2.0), range: NSRange(location: 0, length: attributedString.length))

        // 행간 스타일 추가
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: attributedString.length))

        // TextView에 세팅
        textView.attributedText = attributedString
        return textView
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
        self.addSubview(noticeTextView)
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
    }
    
    func configureLayout() {
        noticeTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    func fill(notice: String) {
        self.noticeTextView.text = notice
    }
}

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
        return textView
    }()
}

//
//  DailyCalendarSectionBackgroundDecorationView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit

class DailyCalendarSectionBackgroundDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


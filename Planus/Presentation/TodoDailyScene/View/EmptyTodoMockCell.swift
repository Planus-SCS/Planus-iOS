//
//  EmptyTodoMockCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/05.
//

import UIKit

class EmptyTodoMockCell: UICollectionViewCell {
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .lightGray
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        return label
    }()
}

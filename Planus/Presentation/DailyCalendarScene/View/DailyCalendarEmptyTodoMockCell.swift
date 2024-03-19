//
//  EmptyTodoMockCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/05.
//

import UIKit

class DailyCalendarEmptyTodoMockCell: UICollectionViewCell {
    static let reuseIdentifier = "empty-todo-mock-cell"
    
    let leftimageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "cloud")
        return imageView
    }()
    
    let rightimageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "cloud")
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0xA5A5A5)
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        label.text = "늦었다고 생각했을때가 이미 늦었을때다"
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.addArrangedSubview(leftimageView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(rightimageView)
        return stackView
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
        self.addSubview(stackView)
    }
    
    func configureLayout() {
        stackView.snp.makeConstraints {
            $0.width.lessThanOrEqualToSuperview().inset(-20)
            $0.center.equalToSuperview()
            $0.height.equalTo(24)
        }
    }
}

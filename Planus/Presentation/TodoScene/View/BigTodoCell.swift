//
//  BigTodoCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit

class BigTodoCell: UICollectionViewCell {
    static let reuseIdentifier = "big-todo-cell"

    var buttonClosure: (() -> Void)?
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        return label
    }()

    var timeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()

    lazy var checkButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()
    
    var checkImageView: UIImageView = {
        let image = UIImage(named: "checkedBox")
        let imageView = UIImageView(frame: CGRect(
            x: 0,
            y: 0,
            width: 18,
            height: 18
        ))
        imageView.image = image
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var uncheckImageView: UIImageView = {
        let image = UIImage(named: "uncheckedBox")
        let imageView = UIImageView(frame: CGRect(
            x: 0,
            y: 0,
            width: 18,
            height: 18
        ))
        imageView.image = image
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.checkImageView.isHidden = true
        self.uncheckImageView.isHidden = false
    }
    
    func configureView() {
        self.layer.cornerRadius = 9
        self.layer.cornerCurve = .continuous
        
        self.addSubview(checkImageView)
        self.addSubview(uncheckImageView)
        self.addSubview(titleLabel)
        self.addSubview(checkButton)
        self.addSubview(timeLabel)
    }
    
    func configureLayout() {
        
        checkImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(10)
        }
        uncheckImageView.snp.makeConstraints {
            $0.center.equalTo(checkImageView)
        }
        
        checkButton.snp.makeConstraints {
            $0.center.width.height.equalTo(checkImageView)
        }
        
        timeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(checkButton.snp.leading).offset(-13)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-13)
            $0.trailing.lessThanOrEqualTo(checkButton.snp.leading).offset(-13)
        }
    }
    
    func fill(closure: @escaping () -> Void) {
        self.buttonClosure = closure
    }

    func fill(title: String, time: String?, category: TodoCategoryColor) {
        self.checkImageView.isHidden = true
        self.uncheckImageView.isHidden = false
        if let time = time {
            timeLabel.isHidden = false
            timeLabel.text = time
        } else {
            timeLabel.isHidden = true
        }
        titleLabel.text = title
        
        self.backgroundColor = category.todoForCalendarColor
        self.titleLabel.textColor = category.todoThickColor
        self.timeLabel.textColor = category.todoThickColor
    }

    @objc func buttonAction(_ sender: UIButton) {
        self.checkImageView.isHidden = !self.checkImageView.isHidden
        self.uncheckImageView.isHidden = !self.uncheckImageView.isHidden
        buttonClosure?()
    }
}

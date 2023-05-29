//
//  BigTodoCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit

class BigTodoCell: SpringableCollectionViewCell {
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

    lazy var checkButton: TodoCheckButton = {
        let button = TodoCheckButton(frame: .zero)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()
        
    var groupSymbol: UIImageView = {
        let image = UIImage(named: "todoGroup")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image?.size.width ?? 0, height: image?.size.height ?? 0))
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        
        return imageView
    }()
    
    var periodSymbol: UIImageView = {
        let image = UIImage(named: "todoCalendar")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image?.size.width ?? 0, height: image?.size.height ?? 0))
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        
        return imageView
    }()
    
    var memoSymbol: UIImageView = {
        let image = UIImage(named: "todoMemo")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image?.size.width ?? 0, height: image?.size.height ?? 0))
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        
        return imageView
    }()
    
    var symbolStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()

    var trailingComponentStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
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
    
    override func prepareForReuse() {
        checkButton.isOn = false
        
        groupSymbol.isHidden = true
        periodSymbol.isHidden = true
        memoSymbol.isHidden = true
    }
    
    func configureView() {
        self.layer.cornerRadius = 9
        self.layer.cornerCurve = .continuous
        
        self.addSubview(titleLabel)
        
        symbolStackView.addArrangedSubview(memoSymbol)
        symbolStackView.addArrangedSubview(periodSymbol)
        symbolStackView.addArrangedSubview(groupSymbol)
        
        trailingComponentStackView.addArrangedSubview(symbolStackView)
        trailingComponentStackView.addArrangedSubview(timeLabel)
        trailingComponentStackView.addArrangedSubview(checkButton)

        
        self.addSubview(trailingComponentStackView)
    }
    
    func configureLayout() {
        
        symbolStackView.snp.makeConstraints {
            $0.height.equalTo(14)
        }
        
        trailingComponentStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(10)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.lessThanOrEqualTo(trailingComponentStackView.snp.leading).offset(-13)
        }
    }
    
    func fill(closure: @escaping () -> Void) {
        self.buttonClosure = closure
    }

    func fill(title: String, time: String?, category: CategoryColor, isGroup: Bool, isScheduled: Bool, isMemo: Bool, completion: Bool) {

        if let time = time {
            timeLabel.isHidden = false
            timeLabel.text = time.toAPM()
        } else {
            timeLabel.isHidden = true
        }
        titleLabel.text = title
        
        self.backgroundColor = category.todoForCalendarColor
        self.titleLabel.textColor = category.todoThickColor
        self.timeLabel.textColor = category.todoThickColor
        
        groupSymbol.isHidden = !isGroup
        periodSymbol.isHidden = !isScheduled // FIXME: 이거 기간투두임 이름 period로 바꾸자
        memoSymbol.isHidden = !isMemo
        
        groupSymbol.tintColor = category.todoThickColor
        periodSymbol.tintColor = category.todoThickColor
        memoSymbol.tintColor = category.todoThickColor
        
        checkButton.setColor(color: category)
    }

    @objc func buttonAction(_ sender: UIButton) {
        buttonClosure?()
    }
}

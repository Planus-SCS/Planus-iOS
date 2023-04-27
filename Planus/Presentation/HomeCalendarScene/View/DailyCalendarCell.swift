//
//  DailyCalendarCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit

class DailyCalendarCell: UICollectionViewCell {
    
    static let identifier = "daily-calendar-cell"
    
    weak var delegate: DailyCalendarCellDelegate?
    
    override var isSelected: Bool {
      didSet {
        if isSelected {
            UIView.animate(withDuration: 0.01,
                           animations: {
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.alpha = 0.5
                self.backgroundColor = UIColor(hex: 0xDBDAFF)
            })
        } else {
            UIView.animate(withDuration: 0.01,
                           animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.alpha = 1
                self.backgroundColor = nil
                
            })
        }
      }
    }
    
    var views: [UIView] = []
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 2
        stackView.alignment = .fill
        return stackView
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 10)
        label.text = "0"
        return label
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    convenience init(mockFrame frame: CGRect) {
        self.init(frame: frame)
        
        stackView.snp.remakeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(3)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        views.forEach {
            $0.removeFromSuperview()
            stackView.removeArrangedSubview($0)
            $0.snp.removeConstraints()
        }

        views.removeAll()
    }
    
    func configureView() {
        self.contentView.addSubview(numberLabel)
        numberLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.top).offset(5)
            $0.centerX.equalTo(self.contentView.snp.centerX)
        }
        
        self.contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().inset(3)
        }
    }
    
    func fill(delegate: DailyCalendarCellDelegate, day: String, state: MonthStateOfDay, weekDay: WeekDay, todoList: [Todo]?) {
        self.delegate = delegate
        numberLabel.text = day
        
        var alpha: Double
        switch state {
        case .prev:
            alpha = 0.4
        case .current:
            alpha = 1
        case .following:
            alpha = 0.4
        }
        
        switch weekDay {
        case .sat:
            numberLabel.textColor = UIColor(hex: 0x6495F4, a: alpha)
        case .sun:
            numberLabel.textColor = UIColor(hex: 0xEA4335, a: alpha)
        default:
            numberLabel.textColor = UIColor(hex: 0x000000, a: alpha)
        }
        
        fill(todoList: todoList)
    }
    
    func fill(todoList: [Todo]?) {
        todoList?.forEach {
            guard let color = self.delegate?.dailyCalendarCell(self, colorOfCategoryId: $0.categoryId) else { return }
            let todoView = SmallTodoView(text: $0.title, categoryColor: color)
            todoView.snp.makeConstraints {
                $0.height.equalTo(16)
            }
            stackView.addArrangedSubview(todoView)
            views.append(todoView)
        }
    }
}

protocol DailyCalendarCellDelegate: AnyClass {
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfCategoryId: Int) -> CategoryColor?
}

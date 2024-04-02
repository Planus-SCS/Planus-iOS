//
//  DailyCalendarCell.swift
//  Planus
//
//  Created by Sangmin Lee on 3/26/24.
//

import UIKit

class CalendarDailyCell: SpringableCollectionViewCell {
    
    static let identifier = "calendar-daily-cell"
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                UIView.animate(withDuration: 0.001,
                               animations: {
                    self.alpha = 0.5
                    self.backgroundColor = UIColor(hex: 0xDBDAFF)
                })
            } else {
                UIView.animate(withDuration: 0.001,
                               animations: {
                    self.alpha = 1
                    self.backgroundColor = nil
                    
                })
            }
        }
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 6
        return stackView
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 10)
        label.text = "0"
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.isSkeletonable = true
        label.layer.cornerCurve = .continuous
        label.layer.cornerRadius = 8
        return label
    }()
    
    var todayImageView: UIImageView = {
        let image = UIImage(named: "today")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        return imageView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(mockableFrame: CGRect) {
        self.init(frame: mockableFrame)
        
        remakeStackConstForMock()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.subviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        numberLabel.font = UIFont(name: "Pretendard-Regular", size: 10)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        numberLabel.layer.cornerRadius = numberLabel.bounds.width/2
    }
    
    func remakeStackConstForMock() {
        stackView.snp.remakeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(3)
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.bottom.equalToSuperview().inset(3)
        }
    }
}

private extension CalendarDailyCell {
    func configureView() {
        self.addSubview(todayImageView)
        self.addSubview(numberLabel)
        self.addSubview(stackView)
    }
    
    func configureLayout() {
        numberLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(16)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(3)
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.bottom.lessThanOrEqualToSuperview().inset(3)
        }
        
        todayImageView.snp.makeConstraints {
            $0.centerX.equalTo(numberLabel)
            $0.centerY.equalTo(numberLabel).offset(-2)
        }
    }
}

// MARK: Fill day info
extension CalendarDailyCell {
    func fill(day: String, state: MonthStateOfDay, weekDay: WeekDay, isToday: Bool, isHoliday: Bool) {
        numberLabel.text = day
        
        if isToday {
            numberLabel.textColor = .planusWhite
            numberLabel.font = UIFont(name: "Pretendard-Bold", size: 10)
            todayImageView.isHidden = false
        } else {
            numberLabel.textColor = UIColor(hex: isHoliday ? 0xEA4335 : weekDay.textColorHex, a: state.textAlpha)
            todayImageView.isHidden = true
        }
    }
}

extension CalendarDailyCell {
    func fill(periodTodoList: [(Int, TodoSummaryViewModel)], singleTodoList: [(Int, TodoSummaryViewModel)], holiday: (Int, String)?) {
        var currentIndex = 0

        periodTodoList.forEach { (index, todo) in
            stackEmptyView(count: index-currentIndex)
            stackSmallTodoView(title: todo.title, color: todo.categoryColor, startDate: todo.startDate, endDate: todo.endDate, isComplete: todo.isCompleted)
            currentIndex = index + 1
        }
        
        if let singleStartIndex = singleTodoList.first?.0 {
            stackEmptyView(count: singleStartIndex-currentIndex)
            
            singleTodoList.forEach { (index, todo) in
                stackSmallTodoView(title: todo.title, color: todo.categoryColor, startDate: todo.startDate, endDate: todo.endDate, isComplete: todo.isCompleted)
            }
            
            currentIndex = singleStartIndex + singleTodoList.count
        }

        if let holiday {
            let holidayIndex = holiday.0
            let holidayTitle = holiday.1
            stackEmptyView(count: holidayIndex-currentIndex)
            stackHolidayLabel(title: holidayTitle)
        }
    }
    
    func fillAndFit(periodTodoList: [(Int, TodoSummaryViewModel)], singleTodoList: [(Int, TodoSummaryViewModel)], holiday: (Int, String)?) -> CGFloat {
        fill(periodTodoList: periodTodoList, singleTodoList: singleTodoList, holiday: holiday)
        remakeStackConstForMock()
        var targetHeight: CGFloat = 100
        let estimatedSize = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        let estimatedHeight = estimatedSize.height
        return estimatedHeight
    }
    
    func stretch(height: CGFloat) {
        stackView.snp.makeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(4)
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.bottom.lessThanOrEqualToSuperview().inset(3)
        }
        self.contentView.snp.remakeConstraints {
            $0.height.equalTo(height)
        }
    }
}

// MARK: - View Stacker
extension CalendarDailyCell {
    func stackEmptyView(count: Int) {
        (0..<count).forEach { _ in
            let view = UIView(frame: .zero)
            view.snp.makeConstraints {
                $0.width.equalTo(UIScreen.main.bounds.width * Double(1)/Double(7) - 6)
                $0.height.equalTo(18)
            }
            view.backgroundColor = .clear
            stackView.addArrangedSubview(view)
        }
    }
    
    func stackSmallTodoView(title: String, color: CategoryColor, startDate: Date, endDate: Date, isComplete: Bool? = nil) {
        let diff = (Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0) + 1
        var todoView = SmallTodoView(title: title, categoryColor: color, isComplete: isComplete)

        todoView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * Double(1)/Double(7) * Double(diff) - 6)
            $0.height.equalTo(18)
        }
        stackView.addArrangedSubview(todoView)
    }
    
    func stackHolidayLabel(title: String) {
        let titleLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.font = UIFont(name: "Pretendard-SemiBold", size: 10)
            label.textAlignment = .center
            label.textColor =  .planusTintRed.withAlphaComponent(alpha)
            return label
        }()
        titleLabel.text = title
        
        titleLabel.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * Double(1)/Double(7) - 6)
            $0.height.equalTo(18)
        }
        stackView.addArrangedSubview(titleLabel)
    }
}

private extension MonthStateOfDay {
    var textAlpha: CGFloat {
        switch self {
        case .prev, .following:
            return 0.4
        case .current:
            return 1.0
        }
    }
}

private extension WeekDay {
    var textColorHex: Int {
        switch self {
        case .sat:
            return 0x6495F4
        case .sun:
            return 0xEA4335
        default:
            return 0x000000
        }
    }
}

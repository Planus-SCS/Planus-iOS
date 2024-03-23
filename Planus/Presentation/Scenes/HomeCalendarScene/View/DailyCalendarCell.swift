//
//  DailyCalendarCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/25.
//

import UIKit

class DailyCalendarCell: SpringableCollectionViewCell {
    
    static let identifier = "daily-calendar-cell"
    
    weak var delegate: DailyCalendarCellDelegate?
    
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
        
    var contentViewHeightConst: NSLayoutConstraint!
    
    lazy var stackView: TodoStackView = {
        let stackView = TodoStackView(frame: .zero)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    convenience init(mockFrame frame: CGRect) {
        self.init(frame: frame)
        contentViewHeightConst.isActive = false
        
        stackView.snp.remakeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(1)
            $0.bottom.equalToSuperview().inset(3)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.removeAllSubview()
        numberLabel.font = UIFont(name: "Pretendard-Regular", size: 10)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        numberLabel.layer.cornerRadius = numberLabel.bounds.width/2
    }
    
    func configureView() {
        self.addSubview(todayImageView)

        self.addSubview(numberLabel)
        numberLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(16)
        }

        todayImageView.snp.makeConstraints {
            $0.centerX.equalTo(numberLabel)
            $0.centerY.equalTo(numberLabel).offset(-2)
        }
        
        self.addSubview(stackView)
        stackView.frame = CGRect(x: 0, y: 25, width: UIScreen.main.bounds.width, height: 500)
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.makeConstraints {
            $0.height.equalTo(110)
        }
        
        contentViewHeightConst = contentView.constraints.first(where: { $0.firstAttribute == .height })
    }
    
    func fill(day: String, state: MonthStateOfDay, weekDay: WeekDay, isToday: Bool, isHoliday: Bool, height: CGFloat) {
        
        if contentViewHeightConst.constant != height {
            contentViewHeightConst.constant = height
        }

        numberLabel.text = day
        
        var alpha: Double
        switch state {
        case .prev, .following:
            alpha = 0.4
        case .current:
            alpha = 1
        }
        
        if isToday {
            numberLabel.textColor = .white
            numberLabel.font = UIFont(name: "Pretendard-Bold", size: 10)
            todayImageView.isHidden = false
        } else {
            todayImageView.isHidden = true
            if isHoliday {
                numberLabel.textColor = UIColor(hex: 0xEA4335, a: alpha)
            } else {
                switch weekDay {
                case .sat:
                    numberLabel.textColor = UIColor(hex: 0x6495F4, a: alpha)
                case .sun:
                    numberLabel.textColor = UIColor(hex: 0xEA4335, a: alpha)
                default:
                    numberLabel.textColor = UIColor(hex: 0x000000, a: alpha)
                }
            }
        }
    }
        
    func fill(periodTodoList: [(Int, Todo)], singleTodoList: [(Int, Todo)], holiday: (Int, String)?) {
        var currentIndex = 0

        periodTodoList.forEach { (index, todo) in
            guard let color = todo.isGroupTodo ?
                    self.delegate?.dailyCalendarCell(self, colorOfGroupCategoryId: todo.categoryId)
                    : self.delegate?.dailyCalendarCell(self, colorOfCategoryId: todo.categoryId) else { return }
            
            let todoView = generateSmallTodoView(title: todo.title, color: color, startDate: todo.startDate, endDate: todo.endDate, isComplete: todo.isCompleted)

            for _ in (currentIndex..<index) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
            }

            stackView.addArrangedSubview(todoView)
            currentIndex = index + 1
        }
        
        if let singleStartIndex = singleTodoList.first?.0 {
            
            for _ in (currentIndex..<singleStartIndex) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
            }

            singleTodoList.forEach { (index, todo) in
                guard let color = todo.isGroupTodo ?
                        self.delegate?.dailyCalendarCell(self, colorOfGroupCategoryId: todo.categoryId)
                        : self.delegate?.dailyCalendarCell(self, colorOfCategoryId: todo.categoryId) else { return }
                
                let todoView = generateSmallTodoView(title: todo.title, color: color, startDate: todo.startDate, endDate: todo.endDate, isComplete: todo.isCompleted)
                stackView.addArrangedSubview(todoView)
            }
            
            currentIndex = singleStartIndex + singleTodoList.count
        }

        if let holiday {
            
            let holidayIndex = holiday.0
            let holidayTitle = holiday.1
            for _ in (currentIndex..<holidayIndex) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
            }
            
            let holidayView = generateHolidayView(title: holidayTitle)
            stackView.addArrangedSubview(holidayView)
        }
        
    }
    
    func socialFill(periodTodoList: [(Int, SocialTodoSummary)], singleTodoList: [(Int, SocialTodoSummary)], holiday: (Int, String)?) {
        var currentIndex = 0

        periodTodoList.forEach { (index, todo) in

            let todoView = generateSmallTodoView(title: todo.title, color: todo.categoryColor, startDate: todo.startDate, endDate: todo.endDate, isComplete: nil)

            for _ in (currentIndex..<index) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
            }

            stackView.addArrangedSubview(todoView)
            currentIndex = index + 1
        }
        
        if let singleStartIndex = singleTodoList.first?.0 {
            
            for _ in (currentIndex..<singleStartIndex) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
            }

            singleTodoList.forEach { (index, todo) in
                let todoView = generateSmallTodoView(title: todo.title, color: todo.categoryColor, startDate: todo.startDate, endDate: todo.endDate, isComplete: nil)
                stackView.addArrangedSubview(todoView)
            }
            
            currentIndex = singleStartIndex + singleTodoList.count
        }

        if let holiday {
            
            let holidayIndex = holiday.0
            let holidayTitle = holiday.1
            for _ in (currentIndex..<holidayIndex) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
            }
            
            let holidayView = generateHolidayView(title: holidayTitle)
            stackView.addArrangedSubview(holidayView)
        }

    }
    

}

extension DailyCalendarCell {
    func generateSmallTodoView(title: String, color: CategoryColor, startDate: Date, endDate: Date, isComplete: Bool?) -> SmallTodoView {
        let diff = (Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0) + 1
        var todoView = SmallTodoView(frame: CGRect(x: 4, y: 0, width: (UIScreen.main.bounds.width/7)*CGFloat(diff)-8, height: 18), text: title, categoryColor: color, isComplete: isComplete)
        return todoView
    }
        
    func generateClearView() -> UIView {
        let view = UIView(frame: CGRect(x: 4, y: 0, width: (UIScreen.main.bounds.width/7) - 8, height: 18))
        view.backgroundColor = .clear
        return view
    }
    
    func generateHolidayView(title: String) -> UIView {

        var titleLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.font = UIFont(name: "Pretendard-SemiBold", size: 10)
            label.textAlignment = .center
            label.textColor =  UIColor(hex: 0xEA4335, a: alpha)
            return label
        }()
        titleLabel.text = title
        
        titleLabel.frame = CGRect(x: 4, y: 0, width: (UIScreen.main.bounds.width/7) - 8, height: 18)

        return titleLabel
    }
}

protocol DailyCalendarCellDelegate: NSObject {
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfCategoryId: Int) -> CategoryColor?
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfGroupCategoryId id: Int) -> CategoryColor?
}

class TodoStackView: UIView {
    var topY: CGFloat = 0
    var spacing: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addArrangedSubview(_ view: UIView) {
        view.frame = CGRect(x: view.frame.minX, y: topY + spacing, width: view.frame.width, height: view.frame.height)
        topY += (view.frame.height + spacing)
        self.addSubview(view)
    }
    
    func removeAllSubview() {
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
        topY = 0
    }
}

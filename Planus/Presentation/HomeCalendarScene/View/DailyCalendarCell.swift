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
    
    var views: [UIView] = []
    
    var contentViewHeightConst: NSLayoutConstraint!
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        return stackView
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 10)
        label.text = "0"
        label.textAlignment = .center
        label.layer.masksToBounds = true
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
        contentViewHeightConst.isActive = false
        
        stackView.snp.remakeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(1)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        numberLabel.layer.cornerRadius = numberLabel.bounds.width/2
    }
    
    func configureView() { //여기서 콘텐츠뷰의 높이를 조정하기 위해서,,,, 스택뷰 밑에 뭔가를 둬서 크기를 조정해야하나...?
        // 아니다 콘텐츠뷰를 따로 해보자... 콘텐츠뷰? -> 레이아웃 용, 그 외에는? 그냥 용. 콘텐츠뷰를 클리어로? 원래 클리어일걸?
        self.addSubview(numberLabel)
        numberLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(16)
        }
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.makeConstraints {
            $0.height.equalTo(120)
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
            numberLabel.backgroundColor = UIColor(hex: 0x6495F4)
            numberLabel.textColor = .white
            
        } else {
            numberLabel.backgroundColor = .clear
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
                views.append(clearView)
            }

            stackView.addArrangedSubview(todoView)
            views.append(todoView)
            currentIndex = index + 1
        }
        
        if let singleStartIndex = singleTodoList.first?.0 {
            
            for _ in (currentIndex..<singleStartIndex) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
                views.append(clearView)
            }

            singleTodoList.forEach { (index, todo) in
                guard let color = todo.isGroupTodo ?
                        self.delegate?.dailyCalendarCell(self, colorOfGroupCategoryId: todo.categoryId)
                        : self.delegate?.dailyCalendarCell(self, colorOfCategoryId: todo.categoryId) else { return }
                
                let todoView = generateSmallTodoView(title: todo.title, color: color, startDate: todo.startDate, endDate: todo.endDate, isComplete: todo.isCompleted)
                stackView.addArrangedSubview(todoView)
                views.append(todoView)
            }
            
            currentIndex = singleStartIndex + singleTodoList.count
        }

        if let holiday {
            
            let holidayIndex = holiday.0
            let holidayTitle = holiday.1
            for _ in (currentIndex..<holidayIndex) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
                views.append(clearView)
            }
            
            let holidayView = generateHolidayView(title: holidayTitle)
            stackView.addArrangedSubview(holidayView)
            views.append(holidayView)
        }
        
    }
    
    func socialFill(periodTodoList: [(Int, SocialTodoSummary)], singleTodoList: [(Int, SocialTodoSummary)], holiday: (Int, String)?) {
        var currentIndex = 0

        periodTodoList.forEach { (index, todo) in

            let todoView = generateSmallTodoView(title: todo.title, color: todo.categoryColor, startDate: todo.startDate, endDate: todo.endDate, isComplete: nil)

            for _ in (currentIndex..<index) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
                views.append(clearView)
            }

            stackView.addArrangedSubview(todoView)
            views.append(todoView)
            currentIndex = index + 1
        }
        
        if let singleStartIndex = singleTodoList.first?.0 {
            
            for _ in (currentIndex..<singleStartIndex) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
                views.append(clearView)
            }

            singleTodoList.forEach { (index, todo) in
                let todoView = generateSmallTodoView(title: todo.title, color: todo.categoryColor, startDate: todo.startDate, endDate: todo.endDate, isComplete: nil)
                stackView.addArrangedSubview(todoView)
                views.append(todoView)
            }
            
            currentIndex = singleStartIndex + singleTodoList.count
        }

        if let holiday {
            
            let holidayIndex = holiday.0
            let holidayTitle = holiday.1
            for _ in (currentIndex..<holidayIndex) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
                views.append(clearView)
            }
            
            let holidayView = generateHolidayView(title: holidayTitle)
            stackView.addArrangedSubview(holidayView)
            views.append(holidayView)
        }

    }
    

}

extension DailyCalendarCell {
    func generateSmallTodoView(title: String, color: CategoryColor, startDate: Date, endDate: Date, isComplete: Bool?) -> SmallTodoView {
        var todoView = SmallTodoView(text: title, categoryColor: color, isComplete: isComplete)
        let diff = (Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0) + 1
        todoView.snp.makeConstraints {
            $0.height.equalTo(16)
            $0.width.equalTo((UIScreen.main.bounds.width/7)*CGFloat(diff) - 1)
        }
        return todoView
    }
        
    func generateClearView() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.snp.makeConstraints {
            $0.height.equalTo(16)
            $0.width.equalTo((UIScreen.main.bounds.width/7) - 1)
        }
        return view
    }
    
    func generateHolidayView(title: String) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
                
        var titleLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.font = UIFont(name: "Pretendard-Regular", size: 10)
            label.textAlignment = .center
            label.textColor =  UIColor(hex: 0xEA4335, a: alpha)
            return label
        }()
        titleLabel.text = title
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
        }
        
        view.snp.makeConstraints {
            $0.height.equalTo(16)
            $0.width.equalTo((UIScreen.main.bounds.width/7) - 1)
        }
        return view
    }
}

protocol DailyCalendarCellDelegate: NSObject {
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfCategoryId: Int) -> CategoryColor?
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfGroupCategoryId id: Int) -> CategoryColor?
}

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
                UIView.animate(withDuration: 0.01,
                               animations: {
                    self.alpha = 0.5
                    self.backgroundColor = UIColor(hex: 0xDBDAFF)
                })
            } else {
                UIView.animate(withDuration: 0.01,
                               animations: {
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
        stackView.spacing = 2
        stackView.alignment = .leading
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
    
    func configureView() {
        self.addSubview(numberLabel)
        numberLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(5)
            $0.centerX.equalTo(self.snp.centerX)
        }
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview()
        }
    }
    
    func fill(day: String, state: MonthStateOfDay, weekDay: WeekDay) {
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
    }
        
    func fill(periodTodoList: [(Int, Todo)], singleTodoList: [(Int, Todo)]) {
        var currentIndex = 0

        periodTodoList.forEach { (index, todo) in
            let todoView = generateSmallTodoView(todo: todo)

            for _ in (currentIndex..<index) {
                let clearView = generateClearView()
                stackView.addArrangedSubview(clearView)
                views.append(clearView)
            }

            stackView.addArrangedSubview(todoView)
            views.append(todoView)
            currentIndex = index + 1
        }

        guard let startIndex = singleTodoList.first?.0 else { return }

        for _ in (currentIndex..<startIndex) {
            let clearView = generateClearView()
            stackView.addArrangedSubview(clearView)
            views.append(clearView)
        }

        singleTodoList.forEach { (index, todo) in
            let view = generateSmallTodoView(todo: todo)
            stackView.addArrangedSubview(view)
            views.append(view)
        }
        
        // views.count가 총 높이가 되는거임!!!
    }
    
    func fill(socialTodoList: [SocialTodoSummary]) {
        socialTodoList.forEach {
            var todoView: SmallTodoView
            todoView = SmallTodoView(text: $0.title, categoryColor: $0.categoryColor)
            
            todoView.snp.makeConstraints {
                $0.height.equalTo(16)
            }
            stackView.addArrangedSubview(todoView)
            views.append(todoView)
        }
    }
    

}

extension DailyCalendarCell {
    func generateSmallTodoView(todo: Todo) -> SmallTodoView {
        var todoView: SmallTodoView
        if let color = todo.isGroupTodo ?
            self.delegate?.dailyCalendarCell(self, colorOfGroupCategoryId: todo.categoryId)
            : self.delegate?.dailyCalendarCell(self, colorOfCategoryId: todo.categoryId) {
            todoView = SmallTodoView(text: todo.title, categoryColor: color)
        } else {
            todoView = SmallTodoView(text: todo.title, categoryColor: .none)
        }
        let diff = (Calendar.current.dateComponents([.day], from: todo.startDate, to: todo.endDate).day ?? 0) + 1
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
    
    func mockFill(todoCount: Int) {
        (0..<todoCount).forEach { _ in
            var todoView = generateClearView()
            stackView.addArrangedSubview(todoView)
            views.append(todoView)
        }
    }
}

protocol DailyCalendarCellDelegate: NSObject {
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfCategoryId: Int) -> CategoryColor?
    func dailyCalendarCell(_ dayCalendarCell: DailyCalendarCell, colorOfGroupCategoryId id: Int) -> CategoryColor?
}

/*
 1. 그 주차의 기간 todo 중 나와 기간이 겹치는 놈이 있는지 탐색 -> 없으면 0번
 2. 겹치는 놈 있는데 그놈이 나보다 빨리 시작해서 빨리끝나거나 같이 끝나면? 그중  -> 그놈 재귀로 들어가서 인덱스 구해오기 ->
 3. 겹치는 놈이
 */

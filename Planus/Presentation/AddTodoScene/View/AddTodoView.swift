//
//  AddTodoView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/29.
//

import UIKit

class AddTodoView: UIView {
    
    lazy var titleField: UITextField = {
        let titleField = UITextField(frame: .zero)
        titleField.placeholder = "일정을 입력하세요"
        titleField.font = UIFont(name: "Pretendard-Medium", size: 20)
        titleField.textColor = .black
        return titleField
    }()
        
    var memoHeightConstraint: NSLayoutConstraint!
    var fieldInitHeight: CGFloat = 30
    var memoMaxHeight: CGFloat = 50
    
    lazy var memoTextView: PlaceholderTextView = {
        let textView = PlaceholderTextView(frame: .zero)
        textView.textContainer.lineFragmentPadding = 0
        textView.text = ""
        textView.placeholder = "메모를 입력하세요"
        textView.placeholderColor = UIColor(hex: 0xBFC7D7)
        textView.textContainerInset = .init(top: 4, left: 0, bottom: 4, right: 0)
        textView.textColor = .black
        textView.backgroundColor = UIColor(hex: 0xF5F5FB)
        textView.font = UIFont(name: "Pretendard-Light", size: 16)
        textView.delegate = self
        return textView
    }()
        
    lazy var categoryButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("카테고리", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Light", size: 16)
        button.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var categoryColorView: UIView = {
        let view = UIView(frame: .zero)
        view.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        view.backgroundColor = .gray
        return view
    }()
    
    lazy var categoryStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.addArrangedSubview(categoryButton)
        stack.addArrangedSubview(categoryColorView)
        return stack
    }()
    
    var headerBarView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    var removeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("삭제", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
        button.setTitleColor(UIColor(hex: 0xEB6955), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    var saveButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
        button.setTitleColor(UIColor(hex: 0x6495F4), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "일정/투두 관리"
        label.font = UIFont(name: "Pretendard-Light", size: 16)
        label.sizeToFit()
        return label
    }()
    
    lazy var startDateButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("2000.00.00", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Light", size: 16)
        button.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var endDateButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("2000.00.00", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Light", size: 16)
        button.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
        button.sizeToFit()

        return button
    }()
    
    lazy var dateArrowView: UIImageView = {
        let image = UIImage(named: "arrow_white") ?? UIImage()
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        view.image = image
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var dateStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.addArrangedSubview(startDateButton)
        stackView.addArrangedSubview(dateArrowView)
        stackView.addArrangedSubview(endDateButton)
        return stackView
    }()
    
    lazy var dateTimeStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubview(dateStackView)
        stackView.addArrangedSubview(timeField)
        return stackView
    }()
    
    let timeField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "00:00"
        textField.font = UIFont(name: "Pretendard-Light", size: 16)
        textField.textColor = .black
        textField.keyboardType = .numberPad
        textField.sizeToFit()
        return textField
    }()
    
    lazy var groupSelectionField: UITextField = {
        let field = UITextField(frame: .zero)
        field.placeholder = "그룹 선택"
        field.font = UIFont(name: "Pretendard-Light", size: 16)
        field.textColor = .black
        field.sizeToFit()
        return field
    }()
    
    var contentStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        return stack
    }()
    
    var separatorView: [UIView] = {
        return (0..<5).map { _ in
            let view = UIView(frame: .zero)
            view.backgroundColor = UIColor(hex: 0xBFC7D7)
            return view
        }
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
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        
        self.addSubview(headerBarView)
        headerBarView.addSubview(titleLabel)
        headerBarView.addSubview(saveButton)
        headerBarView.addSubview(removeButton)

        [titleField,
         separatorView[0],
         categoryStackView,
         separatorView[1],
         dateTimeStackView,
         separatorView[2],
         groupSelectionField,
         separatorView[3],
         memoTextView,
         separatorView[4]
        ].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        self.addSubview(contentStackView)
    }

    func configureLayout() {
        
        titleField.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(fieldInitHeight)
        }
 
        categoryStackView.snp.makeConstraints {
            $0.height.equalTo(fieldInitHeight)
        }

        dateTimeStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(fieldInitHeight)
        }

        
        groupSelectionField.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(fieldInitHeight)
        }
        
        memoTextView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(fieldInitHeight)
        }
        memoHeightConstraint = memoTextView.constraints.first(where: { $0.firstAttribute == .height })
        separatorView.forEach { view in
            view.snp.makeConstraints {
                $0.height.equalTo(0.7)
                $0.width.equalToSuperview()
            }
        }

        headerBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(84)
            $0.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        removeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(headerBarView.snp.bottom)
        }
    }
    
    func layoutTextViewLines() {
        let lines = memoTextView.numberOfLines
        if lines >= 2 {
            self.memoHeightConstraint.constant = memoMaxHeight
        } else {
            self.memoHeightConstraint.constant = fieldInitHeight
        }
        memoTextView.layoutIfNeeded()
    }
}

extension AddTodoView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) { //줄단위로 말고 const 단위로 맞추자
        if textView == memoTextView {
            layoutTextViewLines()
        }
    }
}

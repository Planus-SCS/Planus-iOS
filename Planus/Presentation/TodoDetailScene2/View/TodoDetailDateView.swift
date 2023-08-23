//
//  TodoDetailDateView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/23.
//

import UIKit

class TodoDetailDateView: UIView {
    var startDateLabel: UILabel = {
        let label = PaddingLabel(inset: .init(top: 10, left: 18, bottom: 10, right: 18))
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(hex: 0xBFC7D7).cgColor
        label.layer.cornerCurve = .continuous
        label.layer.cornerRadius = 10
        return label
    }()
    
    var endDateLabel: UILabel = {
        let label = PaddingLabel(inset: .init(top: 10, left: 18, bottom: 10, right: 18))
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(hex: 0xBFC7D7).cgColor
        label.layer.cornerCurve = .continuous
        label.layer.cornerRadius = 10
        return label
    }()
    
    var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.spacing = 13
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
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
        stackView.addArrangedSubview(startDateLabel)
        stackView.addArrangedSubview(endDateLabel)
    }
    
    func configureLayout() {
        stackView.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(20)
        }
    }
    
    func setDate(startDate: String? = nil, endDate: String? = nil) {
        switch (startDate, endDate) {
        case (.some(let start), .some(let end)):
            startDateLabel.text = start
            setEnabled(label: startDateLabel)
            endDateLabel.text = end
            setEnabled(label: endDateLabel)
            UIView.animate(withDuration: 0.1, delay: 0, animations: {
                self.endDateLabel.isHidden = false
            })
            break
        case (.some(let start), .none):
            startDateLabel.text = start
            setEnabled(label: startDateLabel)
            setDisabled(label: endDateLabel)
            UIView.animate(withDuration: 0.1, delay: 0, animations: {
                self.endDateLabel.isHidden = true
            })
        default:
            setDisabled(label: startDateLabel)
            setDisabled(label: endDateLabel)
            UIView.animate(withDuration: 0.1, delay: 0, animations: {
                self.endDateLabel.isHidden = true
            })
            break
        }
    }
    
    func setDisabled(label: UILabel) {
        label.text = "2000년 0월 0일"
        label.textColor = .gray
        label.layer.borderColor = UIColor(hex: 0xBFC7D7).cgColor
    }
    
    func setEnabled(label: UILabel) {
        label.textColor = .black
        label.layer.borderColor = UIColor(hex: 0xADC5F8).cgColor
    }
    
}

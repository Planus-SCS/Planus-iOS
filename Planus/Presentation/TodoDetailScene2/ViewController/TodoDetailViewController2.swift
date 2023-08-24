//
//  TodoDetailViewController2.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/23.
//

import UIKit
import RxSwift
/*
 만약 지금 생각한대로 안쪽을 네비게이션으로 만든다면? 밖에서 navi 자체의 레이아웃을 잡을 줄 알아야하는데,,, 이게 말처럼 쉬운게 아니다 사실...
 계속 바깥부모한테 얼마얼마만큼으로 높이를 조절하라고 전달해야하는데,,, 높이는 또 어떻게 계산해야하는데???? 일단 이대로 하자...
 */
class TodoDetailView2: UIView {
    
    var bag = DisposeBag()
    
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
        label.text = "일정/할일 관리"
        label.font = UIFont(name: "Pretendard-Light", size: 16)
        label.sizeToFit()
        return label
    }()
    
    var contentView = UIView(frame: .zero)
    
    // 스택뷰 말고? 가운데 컨텐츠 뷰를 두고 여기다가 싹다 레이아웃 맞춰놓은 다음에 숨겨봐..?
    
    var titleView = TodoDetailTitleView(frame: .zero)
    var dateView = TodoDetailDateView(frame: .zero)
    var clockView = TodoDetailClockView(frame: .zero)
    var groupView = TodoDetailGroupView(frame: .zero)
    var memoView = TodoDetailMemoView(frame: .zero)
    var icnView = TodoDetailIcnView(frame: .zero)
    
    lazy var attributeViewGroup: [TodoDetailAttributeView] = [titleView, dateView, clockView, groupView, memoView]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .gray
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
        headerBarView.addSubview(removeButton)
        headerBarView.addSubview(titleLabel)
        headerBarView.addSubview(saveButton)
        self.addSubview(titleView)
        self.addSubview(contentView)
        attributeViewGroup.filter { $0 != titleView }.forEach {
            contentView.addSubview($0)
            $0.alpha = 0
        }
        self.addSubview(icnView)
    }
    
    func configureLayout() {
        icnView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.bottom.equalTo(icnView.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        
        titleView.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        attributeViewGroup.filter { $0 != titleView }.forEach {
            $0.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                
            }
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.bottomConstraint = $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            $0.bottomConstraint.isActive = false
        }
        
        
        headerBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
            $0.bottom.equalTo(titleView.snp.top)
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
        
    }
}


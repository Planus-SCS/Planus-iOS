//
//  JoinedGroupDetailHeaderTab.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit

class JoinedGroupDetailHeaderTabView: UIView {
    
    var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    var shadowView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 2
        view.layer.masksToBounds = false
        return view
    }()
    
    var titleButtonList: [UIButton] = {
        return ["공지사항", "그룹캘린더", "그룹채팅"].map { text in
            let button = UIButton(frame: .zero)
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
            button.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
            return button
        }
    }()
    
    lazy var headerStack: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .white
        titleButtonList.forEach {
            stackView.addArrangedSubview($0)
        }
        return stackView
    }()
    
    var statusBackGroundView = UIView(frame: .zero)
    
    var statusBarView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: 0x6F81A9)
        return view
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
        self.clipsToBounds = false
        
        self.addSubview(shadowView)
        shadowView.addSubview(contentView)
        
        contentView.addSubview(headerStack)
        contentView.addSubview(statusBackGroundView)
        statusBackGroundView.addSubview(statusBarView)
        titleButtonList.first?.setTitleColor(UIColor(hex: 0x6F81A9), for: .normal)
    }
    
    func configureLayout() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        headerStack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(3)
        }
        
        statusBackGroundView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(3)
        }
        
        statusBarView.snp.makeConstraints {
            $0.width.equalToSuperview().dividedBy(3)
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
        }
    }
    
    func scrollToTab(index: Int) {
        statusBarView.snp.updateConstraints {
            $0.leading.equalTo(UIScreen.main.bounds.size.width/3*CGFloat(index))
        }
        (0..<titleButtonList.count).forEach {
            if $0 == index {
                titleButtonList[$0].setTitleColor(UIColor(hex: 0x6F81A9), for: .normal)
            } else {
                titleButtonList[$0].setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
            }
        }
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.layoutIfNeeded()
        })
    }
}

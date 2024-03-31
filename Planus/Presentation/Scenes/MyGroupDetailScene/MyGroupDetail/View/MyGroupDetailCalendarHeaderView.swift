//
//  MyGroupDetailCalendarHeaderView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/04.
//

import UIKit
import RxSwift
import RxCocoa

class MyGroupDetailCalendarHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "my-group-detail-calendar-header-view"
    
    var bag: DisposeBag?
    
    lazy var yearMonthButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("2020년 0월", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.setImage(UIImage(named: "downButton"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: -5)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 3
        button.layer.cornerCurve = .continuous
        button.isSkeletonable = true
        return button
    }()
    
    var weakStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.distribution = .fillEqually

        let dayOfTheWeek = ["월", "화", "수", "목", "금", "토", "일"]
        for i in 0..<7 {
            let label = UILabel()
            label.text = dayOfTheWeek[i]
            label.textAlignment = .center
            label.font = UIFont(name: "Pretendard-Regular", size: 12)
            stackView.addArrangedSubview(label)
        }
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
        self.addSubview(yearMonthButton)
        self.addSubview(weakStackView)
    }
    
    func configureLayout() {
        
        yearMonthButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
        }
        
        weakStackView.snp.makeConstraints {
            $0.top.equalTo(yearMonthButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func fill(title: String, btnTapped: PublishRelay<Void>) {
        let bag = DisposeBag()
        yearMonthButton.setTitle(title, for: .normal)
        yearMonthButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                btnTapped.accept(())
            })
            .disposed(by: bag)
        self.bag = bag
    }
    
}

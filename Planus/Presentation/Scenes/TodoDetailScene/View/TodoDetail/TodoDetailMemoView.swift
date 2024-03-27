//
//  TodoDetailMemoView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/23.
//

import UIKit
import RxSwift
import RxCocoa

class TodoDetailMemoView: UIView, TodoDetailAttributeView {
    var bottomConstraint: NSLayoutConstraint!
        
    var bag = DisposeBag()
    
    var isMemoActive = BehaviorRelay<Bool?>(value: nil)
    lazy var memoObservable = Observable.combineLatest(
        isMemoActive.compactMap { $0 }.asObservable(),
        memoTextView.rx.text.asObservable()
    ).map { args -> String? in
        let (isActive, text) = args
        guard isActive else { return nil }
        return text ?? String()
    }
    
    lazy var memoHeightConstraint: NSLayoutConstraint = {
        return memoTextView.heightAnchor.constraint(equalToConstant: 70)
    }()
    
    let memoInitHeight: CGFloat = 30
    let memoMaxHeight: CGFloat = 90
    
    lazy var memoTextView: PlaceholderTextView = {
        let textView = PlaceholderTextView(frame: .zero)
        textView.textContainer.lineFragmentPadding = 0
        textView.text = ""
        textView.placeholder = "메모를 입력하세요"
        textView.placeholderColor = UIColor(hex: 0xBFC7D7)
        textView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        textView.textColor = .black
        textView.backgroundColor = UIColor(hex: 0xF5F5FB)
        textView.font = UIFont(name: "Pretendard-Regular", size: 16)
        textView.layer.borderWidth = 1
        textView.layer.cornerCurve = .continuous
        textView.layer.cornerRadius = 10
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = true
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        memoTextView.rx.text
            .compactMap { $0 }
            .subscribe(onNext: { text in
                self.memoTextView.layer.borderColor = text.isEmpty ?
                UIColor(hex: 0xBFC7D7).cgColor : UIColor(hex: 0xADC5F8).cgColor
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.addSubview(memoTextView)
    }
    
    func configureLayout() {
        memoTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(130)
        }
    }
}

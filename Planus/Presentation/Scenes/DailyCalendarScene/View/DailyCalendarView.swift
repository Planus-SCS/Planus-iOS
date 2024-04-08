//
//  DailyCalendarView.swift
//  Planus
//
//  Created by Sangmin Lee on 3/26/24.
//

import UIKit
import RxSwift

final class DailyCalendarView: UIView {
    lazy var addTodoButton: UIBarButtonItem = {
        let image = UIImage(named: "plusBtn")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .planusBlack
        return item
    }()
    
    lazy var dateTitleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.setTitleColor(.planusBlack, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.isHidden = true
        return spinner
    }()
    
    lazy var collectionView: DailyCalendarCollectionView = {
        let cv = DailyCalendarCollectionView(frame: .zero)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: configure UI
extension DailyCalendarView {
    func configureView() {
        self.backgroundColor = .planusBackgroundColor
        self.addSubview(collectionView)
        self.addSubview(spinner)
    }
    
    func configureLayout() {
        dateTitleButton.snp.makeConstraints {
            $0.width.equalTo(160)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        spinner.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(50)
        }
    }
}

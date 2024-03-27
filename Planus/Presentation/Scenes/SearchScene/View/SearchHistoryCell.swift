//
//  SearchHistoryCell.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/27.
//

import UIKit
import RxSwift

class SearchHistoryCell: SpringableCollectionViewCell {
    static let reuseIdentifier = "search-history-cell"
    
    var removeClosure: (() -> Void)?
    
    var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = .black
        return label
    }()
    
    lazy var removeBtn: UIButton = {
        let image = UIImage(named: "removeBtn")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(removeBtnTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func removeBtnTapped(_ sender: UIButton) {
        removeClosure?()
    }
    
    var separateView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .lightGray
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
        self.addSubview(label)
        self.addSubview(removeBtn)
        self.addSubview(separateView)
    }
    
    func configureLayout() {
        removeBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
        }
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(8)
            $0.trailing.lessThanOrEqualTo(removeBtn.snp.leading).offset(-10)
        }
        
        separateView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.3)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    func fill(keyWord: String) {
        self.label.text = keyWord
    }
}

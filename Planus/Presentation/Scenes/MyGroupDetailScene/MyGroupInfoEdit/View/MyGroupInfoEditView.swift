//
//  MyGroupInfoEditView.swift
//  Planus
//
//  Created by Sangmin Lee on 3/26/24.
//

import UIKit

final class MyGroupInfoEditView: UIView {
    let scrollView = UIScrollView(frame: .zero)
    
    let contentStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()
    
    let infoView: GroupEditInfoView = .init(frame: .zero)
    let tagView: GroupCreateTagView = .init(frame: .zero)
    let limitView: GroupCreateLimitView = .init(frame: .zero)
    let removeButtonView: WideButtonView = {
        let view = WideButtonView.init(frame: .zero)
        view.wideButton.backgroundColor = .systemPink
        view.wideButton.setTitle("그룹 삭제하기", for: .normal)
        return view
    }()
    
    lazy var saveButton: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "saveBarBtn"), style: .plain, target: nil, action: nil)
        item.tintColor = .planusTintBlue
        return item
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.tintColor = .planusBlack
        return item
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

private extension MyGroupInfoEditView {
    func configureView() {
        self.backgroundColor = .planusBackgroundColor
        self.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(infoView)
        contentStackView.addArrangedSubview(tagView)
        contentStackView.addArrangedSubview(limitView)
        contentStackView.addArrangedSubview(removeButtonView)
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.safeAreaLayoutGuide)
        }
        contentStackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
    }
}

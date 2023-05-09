//
//  GroupCreateViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupCreateViewController: UIViewController {
        
    var scrollView = UIScrollView(frame: .zero)
    
    var contentStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()
    
    var infoView: GroupCreateInfoView = .init(frame: .zero)
    var tagView: GroupCreateTagView = .init(frame: .zero)
    var limitView: GroupCreateLimitView = .init(frame: .zero)
    
    var createButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("그룹 생성하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: 0x6495F4)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    @objc func backBtnAction() {
        navigationController?.popViewController(animated: true)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureLayout()
        
        self.navigationItem.setLeftBarButton(backButton, animated: false)
        self.navigationItem.title = "그룹 생성"
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(infoView)
        contentStackView.addArrangedSubview(tagView)
        contentStackView.addArrangedSubview(limitView)
        contentStackView.addArrangedSubview(createButton)
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentStackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }

        createButton.snp.makeConstraints {
            $0.top.equalTo(maxLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(22)
        }
    }
    
    
}

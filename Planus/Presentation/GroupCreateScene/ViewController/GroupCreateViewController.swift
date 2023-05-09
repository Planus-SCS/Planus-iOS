//
//  GroupCreateViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupCreateViewController: UIViewController {
        
    var scrollView = UIScrollView(frame: .zero)
    
    var contentView = UIView(frame: .zero)
    
    
    var limitTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹 인원을 설정하세요"
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        return label
    }()
    
    var limitDescLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "숫자를 클릭하여 입력하세요"
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()
    
    var limitField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        
        textField.textAlignment = .center
        textField.addSidePadding(padding: 10)

        textField.attributedPlaceholder = NSAttributedString(
            string: "50",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x7A7A7A)]
        )
        return textField
    }()
    
    var limitLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "명"
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }()
    
    var maxLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "최대 인원"
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }()
    
    var fiftyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "50명"
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }()
    
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
        scrollView.addSubview(contentView)

        contentView.addSubview(limitTitleLabel)
        contentView.addSubview(limitDescLabel)
        contentView.addSubview(limitField)
        contentView.addSubview(limitLabel)
        contentView.addSubview(maxLabel)
        contentView.addSubview(fiftyLabel)
        contentView.addSubview(createButton)
    }
    
    override func viewDidLayoutSubviews() {
        print(contentView.frame)
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        
        
        limitTitleLabel.snp.makeConstraints {
            $0.top.equalTo(charcaterValidateLabel.snp.bottom).offset(50)
            $0.leading.equalToSuperview().inset(20)
        }
        
        limitDescLabel.snp.makeConstraints {
            $0.top.equalTo(limitTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(20)
        }
        
        limitField.snp.makeConstraints {
            $0.top.equalTo(limitDescLabel.snp.bottom).offset(12)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        
        limitLabel.snp.makeConstraints {
            $0.centerY.equalTo(limitField)
            $0.leading.equalTo(limitField.snp.trailing).offset(8)
        }
        
        maxLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(limitField.snp.bottom).offset(12)
        }
        
        fiftyLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(limitField.snp.bottom).offset(12)
        }
        
        createButton.snp.makeConstraints {
            $0.top.equalTo(maxLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(22)
        }
    }
    
    
}

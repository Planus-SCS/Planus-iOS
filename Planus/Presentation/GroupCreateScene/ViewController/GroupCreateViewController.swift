//
//  GroupCreateViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit

class GroupCreateViewController: UIViewController {
    
//    var scrollView = UIScrollView(frame: .zero)
    
    var scrollView = UIScrollView(frame: .zero)
    
    var contentView = UIView(frame: .zero)
    
    var groupIntroduceTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹 소개를 입력해주세요"
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        return label
    }()
    
    var groupIntroduceDescLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹 사진, 이름, 소개는 필수입력 정보입니다."
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()
    
    var groupImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "GroupCreateDefaultImage")
        return imageView
    }()
    
    var groupImageButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "cameraBtn"), for: .normal)
        return button
    }()
    
    var groupNameField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.addSidePadding(padding: 10)
        textField.attributedPlaceholder = NSAttributedString(
            string: "그룹 이름을 입력하세요",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x7A7A7A)]
        )

        return textField
    }()
    
    var groupNoticeTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isScrollEnabled = false
        textView.text = "간단한 그룹소개 및 공지사항을 입력해주세요"
        textView.textColor = UIColor(hex: 0xBFC7D7)
        textView.backgroundColor = .white
        textView.font = UIFont(name: "Pretendard-Light", size: 16)
        textView.textContainer.lineFragmentPadding = 10
        textView.backgroundColor = .white
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        return textView
    }()
    
    var keyWordTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹과 관련된 키워드를 입력하세요"
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        return label
    }()
    
    var keyWordDescLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "박스 클릭 후 글자를 입력하세요"
        label.textColor = UIColor(hex: 0x6F81A9)
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()
    
    var tagField1: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.addSidePadding(padding: 10)

        textField.attributedPlaceholder = NSAttributedString(
            string: "필수태그입력칸",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x7A7A7A)]
        )
        return textField
    }()
    
    var tagField2: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0xBFC7D7).cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.addSidePadding(padding: 10)

        textField.attributedPlaceholder = NSAttributedString(
            string: "선택태그입력칸",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBFC7D7)]
        )
        return textField
    }()
    
    var tagField3: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0xBFC7D7).cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.addSidePadding(padding: 10)

        textField.attributedPlaceholder = NSAttributedString(
            string: "선택태그입력칸",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBFC7D7)]
        )
        return textField
    }()
    var tagFirstStack: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    var tagField4: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0xBFC7D7).cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.addSidePadding(padding: 10)

        textField.attributedPlaceholder = NSAttributedString(
            string: "선택태그입력칸",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBFC7D7)]
        )
        return textField
    }()
    var tagField5: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0xBFC7D7).cgColor
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.addSidePadding(padding: 10)

        textField.attributedPlaceholder = NSAttributedString(
            string: "선택태그입력칸",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBFC7D7)]
        )
        return textField
    }()
    var tagSecondStack: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    var tagCountValidateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "태그는 최대 5개까지 입력할 수 있어요"
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }()
    
    var stringCountValidateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "한번에 최대 7자 이하만 적을 수 있어요"
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }()
    
    var charcaterValidateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "띄어쓰기, 특수 문자는 빼주세요"
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }()
    
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
        contentView.addSubview(groupIntroduceTitleLabel)
        contentView.addSubview(groupIntroduceDescLabel)
        contentView.addSubview(groupImageView)
        contentView.addSubview(groupImageButton)
        contentView.addSubview(groupNameField)
        contentView.addSubview(groupNoticeTextView)
        contentView.addSubview(keyWordTitleLabel)
        contentView.addSubview(keyWordDescLabel)
        contentView.addSubview(tagField1)
        
        contentView.addSubview(tagFirstStack)
        tagFirstStack.addArrangedSubview(tagField2)
        tagFirstStack.addArrangedSubview(tagField3)
        
        contentView.addSubview(tagSecondStack)
        tagSecondStack.addArrangedSubview(tagField4)
        tagSecondStack.addArrangedSubview(tagField5)
        
        contentView.addSubview(tagCountValidateLabel)
        contentView.addSubview(stringCountValidateLabel)
        contentView.addSubview(charcaterValidateLabel)
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
        groupIntroduceTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(24)
        }
        
        groupIntroduceDescLabel.snp.makeConstraints {
            $0.top.equalTo(groupIntroduceTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(24)
        }
        
        groupImageView.snp.makeConstraints {
            $0.top.equalTo(groupIntroduceDescLabel.snp.bottom).offset(20)
            $0.width.height.equalTo(120)
            $0.centerX.equalToSuperview()
        }
        
        groupImageButton.snp.makeConstraints {
            $0.width.height.equalTo(34)
            $0.trailing.equalTo(groupImageView.snp.trailing).offset(10)
            $0.bottom.equalTo(groupImageView.snp.bottom).offset(10)
        }
        
        groupNameField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(groupImageView.snp.bottom).offset(20)
            $0.height.equalTo(45)
        }
        
        groupNoticeTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(groupNameField.snp.bottom).offset(10)
            $0.height.equalTo(110)
        }
        
        keyWordTitleLabel.snp.makeConstraints {
            $0.top.equalTo(groupNoticeTextView.snp.bottom).offset(50)
            $0.leading.equalToSuperview().inset(20)
        }
        
        keyWordDescLabel.snp.makeConstraints {
            $0.top.equalTo(keyWordTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(20)
        }
        
        tagField1.snp.makeConstraints {
            $0.top.equalTo(keyWordDescLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(40)
            $0.width.lessThanOrEqualToSuperview().offset(-40)
        }
        
        tagFirstStack.snp.makeConstraints {
            $0.top.equalTo(tagField1.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        tagField2.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(tagFirstStack.snp.width).offset(-50)
        }

        tagField3.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(tagFirstStack.snp.width).offset(-50)
        }
        tagSecondStack.snp.makeConstraints {
            $0.top.equalTo(tagFirstStack.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        tagField4.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(tagSecondStack.snp.width).offset(-50)
        }

        tagField5.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(tagSecondStack.snp.width).offset(-50)
        }
        
        tagCountValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagField4.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        stringCountValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagCountValidateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        charcaterValidateLabel.snp.makeConstraints {
            $0.top.equalTo(stringCountValidateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
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

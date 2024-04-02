//
//  GroupCreateTagView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/19.
//

import UIKit
import RxSwift
import RxCocoa
class GroupCreateTagView: UIView {
        
    var keyWordTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "그룹과 관련된 키워드를 입력하세요"
        label.textColor = .planusBlack
        label.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        return label
    }()
    
    var keyWordDescLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "박스 클릭 후 글자를 입력하세요"
        label.textColor = .planusDeepNavy
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        return label
    }()
    
    lazy var tagCollectionView: UICollectionView = {
        let layout = EqualSpacedCollectionViewLayout.createLayout()

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(GroupCreateTagCell.self, forCellWithReuseIdentifier: GroupCreateTagCell.reuseIdentifier)
        cv.register(GroupCreateTagAddCell.self, forCellWithReuseIdentifier: GroupCreateTagAddCell.reuseIdentifier)
        cv.backgroundColor = .planusBackgroundColor
        return cv
    }()
    
    lazy var tagCountValidateLabel: UILabel = self.validationLabelGenerator(text: "태그는 최대 5개까지 입력할 수 있어요")
    lazy var duplicateValidateLabel: UILabel = self.validationLabelGenerator(text: "태그를 중복 없이 작성 해주세요")

    var tagCountCheckView: ValidationCheckImageView = .init()
    var duplicateValidateCheckView: ValidationCheckImageView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.addSubview(keyWordTitleLabel)
        self.addSubview(keyWordDescLabel)
        self.addSubview(tagCollectionView)

        self.addSubview(tagCountValidateLabel)
        self.addSubview(tagCountCheckView)
        self.addSubview(duplicateValidateLabel)
        self.addSubview(duplicateValidateCheckView)
    }
    
    func configureLayout() {
        keyWordTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        keyWordDescLabel.snp.makeConstraints {
            $0.top.equalTo(keyWordTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(20)
        }
        
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(keyWordDescLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(90)
        }
        
        tagCountValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagCollectionView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tagCountCheckView.snp.makeConstraints {
            $0.centerY.equalTo(tagCountValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        duplicateValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagCountCheckView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().inset(30)
        }
        
        duplicateValidateCheckView.snp.makeConstraints {
            $0.centerY.equalTo(duplicateValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    func validationLabelGenerator(text: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = text
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = .planusDeepNavy
        return label
    }
}

class GroupTagInputViewController: UIViewController {
    var bag = DisposeBag()
    var keyboardAppearWithHeight: ((CGFloat) -> Void)?
    var tagAddclosure: ((String) -> Void)?
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "태그 입력"
        label.font = UIFont(name: "Pretendard-Light", size: 16)
        label.sizeToFit()
        return label
    }()
    
    var tagField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .planusBlack
        textField.font = UIFont(name: "Pretendard-Medium", size: 16)
        
        textField.backgroundColor = .planusWhite
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.clearButtonMode = .whileEditing
        textField.addSidePadding(padding: 10)
        textField.attributedPlaceholder = NSAttributedString(
            string: "태그를 입력해 주세요.",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor.planusPlaceholderColor]
        )

        return textField
    }()
    
    lazy var infoButton: UIButton = {
        let image = UIImage(systemName: "info.circle.fill")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(frame: .zero)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.6)
        button.addTarget(self, action: #selector(infoBtnTapped), for: .touchUpInside)
        return button
    }()
    
    var isInfoViewing: Bool = false
    
    lazy var enterButton: SpringableButton = {
        let button = SpringableButton(frame: .zero)
        button.setTitle("입력", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.backgroundColor = .planusTintBlue
        button.setTitleColor(.planusWhite, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(enterBtnTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var stringCountValidateLabel: UILabel = self.validationLabelGenerator(text: "• 한번에 최대 7자 이하만 적을 수 있어요")
    lazy var charcaterValidateLabel: UILabel = self.validationLabelGenerator(text: "• 띄어쓰기, 특수 문자는 빼주세요")
    
    convenience init(isInfoViewing: Bool) {
        self.init(nibName: nil, bundle: nil)
        
        self.isInfoViewing = isInfoViewing
        self.preferredContentSize = isInfoViewing ?
        CGSize(width: UIScreen.main.bounds.width - 80, height: 110) :
        CGSize(width: UIScreen.main.bounds.width - 80, height: 60)
        
        self.stringCountValidateLabel.isHidden = !isInfoViewing
        self.charcaterValidateLabel.isHidden = !isInfoViewing
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureLayout()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeKeyboardNotifications()
    }
    
    func bind() {
        tagField
            .rx
            .text
            .map { text in
                guard let text else { return false }
                let tagLengthState = text.count > 0 && text.count <= 7
                let tagSpecialCharState = text.checkRegex(regex: "^(?=.*[\\s!@#$%])")
                return tagLengthState && !tagSpecialCharState
            }
            .withUnretained(self)
            .subscribe(onNext: { vc, isFilled in
                vc.enterButton.isEnabled = isFilled
                vc.enterButton.alpha = isFilled ? 1.0 : 0.4
            })
            .disposed(by: bag)
        
    }
    
    func configureView() {
        self.view.backgroundColor = .planusBackgroundColor
        self.view.addSubview(tagField)
        self.view.addSubview(enterButton)
        self.view.addSubview(infoButton)
        self.view.addSubview(stringCountValidateLabel)
        self.view.addSubview(charcaterValidateLabel)
    }
    
    func configureLayout() {
        enterButton.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(40)
            $0.width.equalTo(50)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(40)
        }
        
        infoButton.snp.makeConstraints {
            $0.centerY.equalTo(enterButton)
            $0.height.equalTo(20)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            $0.width.equalTo(20)
        }
        
        tagField.snp.makeConstraints {
            $0.centerY.equalTo(enterButton)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            $0.trailing.equalTo(enterButton.snp.leading).offset(-10)
            $0.height.equalTo(40)
        }
        
        stringCountValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagField.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).inset(16)
        }
        
        charcaterValidateLabel.snp.makeConstraints {
            $0.top.equalTo(stringCountValidateLabel.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    @objc func enterBtnTapped(_ sender: UIButton) {
        guard let tag = tagField.text else { return }
        tagAddclosure?(tag)
        self.dismiss(animated: true)
    }
    
    @objc func infoBtnTapped(_ sender: UIButton) {
        isInfoViewing = !isInfoViewing
        self.preferredContentSize = isInfoViewing ?
        CGSize(width: UIScreen.main.bounds.width - 80, height: 110) :
        CGSize(width: UIScreen.main.bounds.width - 80, height: 60)
        
        self.stringCountValidateLabel.setAnimatedIsHidden(!isInfoViewing)
        self.charcaterValidateLabel.setAnimatedIsHidden(!isInfoViewing)
        
    }
    
    func validationLabelGenerator(text: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = text
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = .planusDeepNavy
        return label
    }
}

extension GroupTagInputViewController {
    func addKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
    }
    
    // 노티피케이션을 제거하는 메서드
    func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        keyboardAppearWithHeight?(keyboardFrame.height)
    }
}

class EqualSpacedCollectionViewLayout: UICollectionViewCompositionalLayout {
    private static let itemSize: NSCollectionLayoutSize = .init(
        widthDimension: .estimated(40),
        heightDimension: .absolute(40)
    )
    private static let sectionInset: NSDirectionalEdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    private static let interItemSpacing: CGFloat = 5

    static func createLayout() -> EqualSpacedCollectionViewLayout {
        let itemSize = itemSize
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 3, bottom: 0, trailing: 3)
        group.interItemSpacing = .fixed(interItemSpacing)
        let section = NSCollectionLayoutSection(group: group)

        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        config.scrollDirection = .vertical
        section.interGroupSpacing = interItemSpacing
        
        let layout = EqualSpacedCollectionViewLayout(section: section)
        layout.configuration = config
        
        return layout
    }
}



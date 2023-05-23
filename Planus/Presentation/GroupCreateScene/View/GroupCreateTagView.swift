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
    
    var viewModel: GroupCreateViewModel?
    weak var delegate: GroupCreateTagViewDelegate?
    
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
    
    lazy var tagCollectionView: UICollectionView = {
        let layout = EqualSpacedCollectionViewLayout()
        layout.estimatedItemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 3
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(GroupCreateTagCell.self, forCellWithReuseIdentifier: GroupCreateTagCell.reuseIdentifier)
        cv.register(GroupCreateTagAddCell.self, forCellWithReuseIdentifier: GroupCreateTagAddCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)
    
        return cv
    }()
    
    lazy var tagCountValidateLabel: UILabel = self.validationLabelGenerator(text: "태그는 최대 5개까지 입력할 수 있어요")
    lazy var stringCountValidateLabel: UILabel = self.validationLabelGenerator(text: "한번에 최대 7자 이하만 적을 수 있어요")
    lazy var charcaterValidateLabel: UILabel = self.validationLabelGenerator(text: "띄어쓰기, 특수 문자는 빼주세요")
    lazy var duplicateValidateLabel: UILabel = self.validationLabelGenerator(text: "태그를 중복 없이 작성 해주세요")

    var tagCountCheckView: ValidationCheckImageView = .init()
    var stringCountCheckView: ValidationCheckImageView = .init()
    var charValidateCheckView: ValidationCheckImageView = .init()
    var duplicateValidateCheckView: ValidationCheckImageView = .init()
    
    convenience init(viewModel: GroupCreateViewModel) {
        self.init(frame: .zero)
        self.viewModel = viewModel
    }
    
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
        self.addSubview(stringCountValidateLabel)
        self.addSubview(stringCountCheckView)
        self.addSubview(charcaterValidateLabel)
        self.addSubview(charValidateCheckView)
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
            $0.height.equalTo(100)
        }
        
        tagCountValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tagCountCheckView.snp.makeConstraints {
            $0.centerY.equalTo(tagCountValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        stringCountValidateLabel.snp.makeConstraints {
            $0.top.equalTo(tagCountValidateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        stringCountCheckView.snp.makeConstraints {
            $0.centerY.equalTo(stringCountValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        charcaterValidateLabel.snp.makeConstraints {
            $0.top.equalTo(stringCountValidateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        charValidateCheckView.snp.makeConstraints {
            $0.centerY.equalTo(charcaterValidateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        duplicateValidateLabel.snp.makeConstraints {
            $0.top.equalTo(charcaterValidateLabel.snp.bottom).offset(10)
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
        label.textColor = UIColor(hex: 0x6F81A9)
        return label
    }
}

extension GroupCreateTagViewTest: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel?.tagList.count == 5 {
            return 5
        } else {
            return (viewModel?.tagList.count ?? 0) + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == (viewModel?.tagList.count ?? 0) {
            return collectionView.dequeueReusableCell(withReuseIdentifier: GroupCreateTagAddCell.reuseIdentifier, for: indexPath)
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupCreateTagCell.reuseIdentifier, for: indexPath) as? GroupCreateTagCell,
                  let tag = viewModel?.tagList[indexPath.item] else {
                return UICollectionViewCell()
            }
            cell.fill(tag: tag)
            cell.removeBtnClosure = { [weak self] in
                self?.delegate?.shouldRemoveTagAt(index: indexPath)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.item == (viewModel?.tagList.count ?? 0) {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return false }
            delegate?.shouldPresentTestVC(cell: cell)
        }
        return false
    }
}

protocol GroupCreateTagViewDelegate: AnyObject {
    func shouldPresentTestVC(cell collectionViewCell: UICollectionViewCell)
    func shouldRemoveTagAt(index: IndexPath)
}

class GroupTagInputViewController: UIViewController {
    var bag = DisposeBag()
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
        textField.textColor = .black
        textField.font = UIFont(name: "Pretendard-Medium", size: 16)
        
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.clearButtonMode = .whileEditing
        textField.addSidePadding(padding: 10)
        textField.attributedPlaceholder = NSAttributedString(
            string: "태그를 입력해 주세요.",
            attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x7A7A7A)]
        )

        return textField
    }()
    
    lazy var enterButton: SpringableButton = {
        let button = SpringableButton(frame: .zero)
        button.setTitle("입력", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.backgroundColor = UIColor(hex: 0x6495F4)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(enterBtnTapped), for: .touchUpInside)
        return button
    }()
    
    var separatorView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .gray
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureLayout()
        
        bind()
    }
    
    func bind() {
        tagField
            .rx
            .text
            .withUnretained(self)
            .subscribe(onNext: { vc, tag in
                let isEmpty = (tag?.isEmpty ?? true)
                vc.enterButton.isEnabled = !isEmpty
                vc.enterButton.alpha = !isEmpty ? 1.0 : 0.4
            })
            .disposed(by: bag)
        
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(tagField)
        self.view.addSubview(enterButton)
    }
    
    func configureLayout() {
        tagField.snp.makeConstraints {
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(86)
            $0.centerY.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        enterButton.snp.makeConstraints {
            $0.centerY.equalTo(tagField)
            $0.height.equalTo(tagField)
            $0.leading.equalTo(tagField.snp.trailing).offset(10)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(10)
        }
    }
    
    @objc func enterBtnTapped(_ sender: UIButton) {
        guard let tag = tagField.text else { return }
        tagAddclosure?(tag)
        self.dismiss(animated: true)
    }
}

class EqualSpacedCollectionViewLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        
        return attributes
    }
}



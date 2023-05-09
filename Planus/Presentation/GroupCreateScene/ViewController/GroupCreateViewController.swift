//
//  GroupCreateViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift

class GroupCreateViewController: UIViewController {

    var bag = DisposeBag()
    var viewModel: GroupCreateViewModel?
    
    var titleImageChanged = PublishSubject<ImageFile?>()
    
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
    var createButtonView: WideButtonView = .init(frame: .zero)
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    @objc func backBtnAction() {
        navigationController?.popViewController(animated: true)
    }
    
    convenience init(viewModel: GroupCreateViewModel) {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
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
    
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setLeftBarButton(backButton, animated: false)
        self.navigationItem.title = "그룹 생성"
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let tagObservableList = [
            tagView.tagField1.rx.text.asObservable(),
            tagView.tagField2.rx.text.asObservable(),
            tagView.tagField3.rx.text.asObservable(),
            tagView.tagField4.rx.text.asObservable(),
            tagView.tagField5.rx.text.asObservable()
        ].map { str in
            return str.map {
                return (($0?.isEmpty) ?? true) ? nil : $0
            }
        }
        
        let tagListChanged = Observable.combineLatest(tagObservableList)
    
        
        let input = GroupCreateViewModel.Input(
            titleChanged: infoView.groupNameField.rx.text.asObservable(),
            noticeChanged: infoView.groupNoticeTextView.rx.text.asObservable(),
            titleImageChanged: titleImageChanged.asObservable(),
            tagListChanged: tagListChanged,
            maxMemberChanged: limitView.limitField.rx.text.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output
            .tagCountValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                print("count", validation)
            })
            .disposed(by: bag)
        
        output
            .tagCharCountValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                print("charCount", validation)
            })
            .disposed(by: bag)
        
        output
            .tagSpecialCharValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                print("special", validation)
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(infoView)
        contentStackView.addArrangedSubview(tagView)
        contentStackView.addArrangedSubview(limitView)
        contentStackView.addArrangedSubview(createButtonView)
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        contentStackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }

    }
    
    
}

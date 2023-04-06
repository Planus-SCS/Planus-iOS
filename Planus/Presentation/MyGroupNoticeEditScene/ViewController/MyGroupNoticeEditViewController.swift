//
//  MyGroupNoticeEditViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit
import RxSwift

class MyGroupNoticeEditViewController: UIViewController {
    
    var bag = DisposeBag()
    var viewModel: MyGroupNoticeEditViewModel?
    
    var noticeTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.layer.cornerRadius = 10
        textView.layer.cornerCurve = .continuous
        textView.font = UIFont(name: "Pretendard-Regular", size: 16)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10

        let attributedString = NSMutableAttributedString(string: textView.text)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: attributedString.length))

        textView.attributedText = attributedString
        return textView
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    lazy var saveButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveBtnAction))
        item.tintColor = UIColor(hex: 0x6495F4)
        return item
    }()
    
    convenience init(viewModel: MyGroupNoticeEditViewModel) {
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
        
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationItem.setRightBarButton(saveButton, animated: false)
        
        configureView()
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.title = "공지사항 관리"
    }
    
    func bind() {
        guard let viewModel else { return }
        let input = MyGroupNoticeEditViewModel.Input(
            didTapSaveButton: saveButton.rx.tap.asObservable(),
            didChangeNoticeValue: noticeTextView.rx.text.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didInitializedNotice
            .bind(to: noticeTextView.rx.text)
            .disposed(by: bag)
        
        output
            .didEditCompleted
            .subscribe(onNext: {
                /*
                 pop 로직 실행
                 */
            })
            .disposed(by: bag)
    }
    
    func configureView() {
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(noticeTextView)
    }
    
    func configureLayout() {
        noticeTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(26)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-300)
        }
    }
    
    @objc func backBtnAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveBtnAction(_ sender: UIBarButtonItem) {
        
    }
}
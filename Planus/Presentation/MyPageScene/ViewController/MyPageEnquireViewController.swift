//
//  MyPageEnquireViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/10.
//

import UIKit
import RxSwift

class MyPageEnquireViewController: UIViewController {
    var bag = DisposeBag()
    var viewModel: MyPageEnquireViewModel?
    
    lazy var enquireTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.layer.cornerRadius = 10
        textView.layer.cornerCurve = .continuous
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(hex: 0x6F81A9).cgColor
        textView.font = UIFont(name: "Pretendard-Regular", size: 16)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.delegate = self
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10

        let attributedString = NSMutableAttributedString(string: textView.text)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: attributedString.length))

        textView.attributedText = attributedString
        textView.text = "문의 사항을 입력 후 저장하세요. 가입 메일을 통해 답변을 보내드립니다."
        textView.textColor = UIColor(hex: 0xBFC7D7)
        return textView
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    lazy var sendButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "전송", style: .plain, target: self, action: #selector(saveBtnAction))
        item.tintColor = UIColor(hex: 0x6495F4)
        return item
    }()
    
    convenience init(viewModel: MyPageEnquireViewModel) {
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
        navigationItem.setRightBarButton(sendButton, animated: false)
        
        configureView()
        configureLayout()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "문의하기"
    }
    
    func bind() {
        guard let viewModel else { return }
        let input = MyPageEnquireViewModel.Input(
            didTapSendButton: sendButton.rx.tap.asObservable(),
            didChangeInquireValue: enquireTextView.rx.text.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
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
        self.view.addSubview(enquireTextView)
    }
    
    func configureLayout() {
        enquireTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(26)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-80)
        }
    }
    
    @objc func backBtnAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveBtnAction(_ sender: UIBarButtonItem) {
        
    }
}

extension MyPageEnquireViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "문의 사항을 입력 후 저장하세요. 가입 메일을 통해 답변을 보내드립니다."
            textView.textColor = UIColor(hex: 0xBFC7D7)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(hex: 0xBFC7D7) {
            textView.text = nil
            textView.textColor = .black
        }
    }
}

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
    
    var isNoticeFilled = false
    var didChangeNoticeValue = PublishSubject<String?>()
    
    lazy var noticeTextView: UITextView = {
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
        textView.delegate = self
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
        
        configureView()
        configureLayout()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.setRightBarButton(saveButton, animated: false)
        
        navigationItem.title = "공지사항 관리"
    }
    
    func bind() {
        guard let viewModel else { return }
        
        guard let notice = try? viewModel.notice.value() else { return }
        noticeTextView.text = notice
        isNoticeFilled = true
        
        let input = MyGroupNoticeEditViewModel.Input(
            didTapSaveButton: saveButton.rx.tap.asObservable(),
            didChangeNoticeValue: didChangeNoticeValue.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .isSaveBtnEnabled
            .withUnretained(self)
            .subscribe(onNext: { vc, isEnabled in
                vc.saveButton.isEnabled = isEnabled
                if isEnabled {
                    vc.saveButton.tintColor = UIColor(hex: 0x6495F4)
                } else {
                    vc.saveButton.tintColor = UIColor(hex: 0x6495F4).withAlphaComponent(0.5)
                }
            })
            .disposed(by: bag)
        
        output
            .didEditCompleted
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
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

extension MyGroupNoticeEditViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "간단한 그룹소개 및 공지사항을 입력해주세요"
            textView.textColor = UIColor(hex: 0x7A7A7A)
            isNoticeFilled = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !(isNoticeFilled) {
            textView.text = nil
            textView.textColor = .black
            isNoticeFilled = true
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if isNoticeFilled && textView == self.noticeTextView {
            if text == "" { //backspace
                if var textString = textView.text,
                   !textString.isEmpty {
                    textString = String(textString.dropLast())
                    textView.text = textString
                    didChangeNoticeValue.onNext(textString)
                }
                return false
            } else if var textString = textView.text {
                if textString.count == 1000 {
                    return false
                }
                textString += text
                
                textView.text = textString
                didChangeNoticeValue.onNext(textString)
                
                return false
            }
        }
        return true
        
    }
}


extension MyGroupNoticeEditViewController: UIGestureRecognizerDelegate {}

//
//  MyGroupNoticeEditViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/04/05.
//

import UIKit
import RxSwift

final class MyGroupNoticeEditViewController: UIViewController {
    
    var bag = DisposeBag()
    
    var viewModel: MyGroupNoticeEditViewModel?
    var myGroupNoticeEditView: MyGroupNoticeEditView?
    
    convenience init(viewModel: MyGroupNoticeEditViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        let view = MyGroupNoticeEditView(frame: self.view.frame)
        self.view = view
        self.myGroupNoticeEditView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let myGroupNoticeEditView else { return }
        
        navigationItem.setLeftBarButton(myGroupNoticeEditView.backButton, animated: false)
        navigationItem.setRightBarButton(myGroupNoticeEditView.saveButton, animated: false)

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.title = "공지사항 관리"
    }
}

// MARK: - bind viewModel
private extension MyGroupNoticeEditViewController {
    func bind() {
        guard let viewModel,
              let myGroupNoticeEditView else { return }
        
        guard let notice = try? viewModel.notice.value() else { return }
        myGroupNoticeEditView.noticeTextView.text = notice

        let input = MyGroupNoticeEditViewModel.Input(
            didTapSaveButton: myGroupNoticeEditView.saveButton.rx.tap.asObservable(),
            didChangeNoticeValue: myGroupNoticeEditView.noticeTextView.rx.text.skip(1).asObservable(),
            backBtnTapped: myGroupNoticeEditView.backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .isSaveBtnEnabled
            .compactMap { $0 }
            .subscribe(onNext: { isEnabled in
                myGroupNoticeEditView.saveButton.isEnabled = isEnabled
                if isEnabled {
                    myGroupNoticeEditView.saveButton.tintColor = .planusTintBlue
                } else {
                    myGroupNoticeEditView.saveButton.tintColor = .planusTintBlue.withAlphaComponent(0.5)
                }
            })
            .disposed(by: bag)
    }
}

private extension MyGroupNoticeEditViewController {
    func configureVC() {
        myGroupNoticeEditView?.noticeTextView.delegate = self
    }
}

extension MyGroupNoticeEditViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = (textView.text?.count)! + text.count - range.length
        return !(newLength > 1000)
    }
}


extension MyGroupNoticeEditViewController: UIGestureRecognizerDelegate {}

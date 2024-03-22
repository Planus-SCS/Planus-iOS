//
//  TodoDetailVC+Keyboard.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/25.
//

import UIKit
import RxSwift

extension TodoDetailViewController {
    @objc func keyboardWillShow(_ notification:NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let newKeyboardBag = DisposeBag()
            keyboardBag = newKeyboardBag
            viewModel?
                .showMessage
                .observe(on: MainScheduler.asyncInstance)
                .withUnretained(self)
                .subscribe(onNext: { vc, message in
                    vc.showToast(
                        message: message.text,
                        type: Message.toToastType(state: message.state),
                        fromBotton: keyboardHeight + 50
                    )
                })
                .disposed(by: newKeyboardBag)
            
            switch pageType {
            case .todoDetail:
                dayPickerViewController.view.snp.remakeConstraints {
                    $0.top.equalTo(todoDetailView.icnView.snp.bottom)
                    $0.leading.trailing.equalToSuperview().inset(10)
                    $0.height.equalTo(keyboardHeight)
                    $0.bottom.equalToSuperview()
                }
            case .selectCategory:
                return
            case .createCategory:
                categoryCreateView.descLabel.snp.remakeConstraints {
                    $0.top.equalTo(categoryCreateView.collectionView.snp.bottom)
                    $0.centerX.equalToSuperview()
                    $0.bottom.equalToSuperview().inset(keyboardHeight+20)
                }
            }
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(_ notification:NSNotification) {
        let newKeyboardBag = DisposeBag()
        keyboardBag = newKeyboardBag
        viewModel?
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message.text, type: Message.toToastType(state: message.state))
            })
            .disposed(by: newKeyboardBag)
        
        switch pageType {
        case .todoDetail, .selectCategory:
            return
        case .createCategory:
            categoryCreateView.descLabel.snp.remakeConstraints {
                $0.top.equalTo(categoryCreateView.collectionView.snp.bottom)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().inset(40)
            }
        }
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
}

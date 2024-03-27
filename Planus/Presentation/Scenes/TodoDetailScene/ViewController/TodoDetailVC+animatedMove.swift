//
//  TodoDetailVC+animatedMove.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/25.
//

import UIKit

extension TodoDetailViewController {
    func firstAppear() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.todoDetailView.snp.remakeConstraints {
                $0.bottom.leading.trailing.equalToSuperview()
                $0.height.lessThanOrEqualTo(700)
            }
            self.dimmedView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }, completion: nil)
        isFirstAppear = false
    }
    func moveFromAddToSelect() {
        guard self.pageType != .selectCategory else { return }

        self.pageType = .selectCategory
        view.endEditing(true)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.todoDetailView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.trailing.equalTo(self.view.snp.leading)
                $0.bottom.equalToSuperview()
                $0.height.lessThanOrEqualTo(700)
            }
            
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveFromSelectToCreate() {
        guard self.pageType != .createCategory else { return }

        self.pageType = .createCategory
        categoryCreateView.nameField.becomeFirstResponder()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.categoryCreateView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view)
                $0.height.lessThanOrEqualTo(800)
                $0.bottom.equalToSuperview()
            }
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.trailing.equalTo(self.view.snp.leading)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveFromCreateToSelect() {
        guard self.pageType != .selectCategory else { return }
        self.pageType = .selectCategory
        view.endEditing(true)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view.snp.leading)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.categoryCreateView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view.snp.trailing)
                $0.height.equalTo(500)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveFromSelectToAdd() {
        guard self.pageType != .todoDetail else { return }
        
        self.pageType = .todoDetail
        todoDetailView.titleView.todoTitleField.becomeFirstResponder()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.todoDetailView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view.snp.leading)
                $0.bottom.equalToSuperview()
                $0.height.lessThanOrEqualTo(700)
            }
            
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.view.snp.trailing)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hideBottomSheetAndGoBack() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.dimmedView.alpha = 0.0
            switch self.pageType {
            case .todoDetail:
                self.todoDetailView.snp.remakeConstraints {
                    $0.leading.trailing.equalToSuperview()
                    $0.top.equalTo(self.dimmedView.snp.bottom)
                    $0.height.lessThanOrEqualTo(700)
                }
            case .selectCategory:
                self.categoryView.snp.remakeConstraints {
                    $0.width.equalToSuperview()
                    $0.leading.equalToSuperview()
                    $0.height.equalTo(400)
                    $0.top.equalTo(self.dimmedView.snp.bottom)
                }
            case .createCategory:
                self.categoryCreateView.snp.remakeConstraints {
                    $0.width.equalToSuperview()
                    $0.leading.equalToSuperview()
                    $0.height.lessThanOrEqualTo(800)
                    $0.top.equalTo(self.dimmedView.snp.bottom)
                }
            }

            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.viewModel?.actions.close?()
            }
        }
    }
}

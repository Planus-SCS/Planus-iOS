//
//  GroupCreateViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class GroupCreateViewController: UIViewController {
    
    private var bag = DisposeBag()
    
    var viewModel: GroupCreateViewModel?
    private var groupCreateView: GroupCreateView?
    
    private let tagAdded = PublishRelay<String>()
    private let tagRemovedAt = PublishRelay<Int>()
    private let titleImageChanged = PublishRelay<ImageFile?>()
    
    convenience init(viewModel: GroupCreateViewModel) {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        let view = GroupCreateView(frame: self.view.frame)
        self.view = view
        self.groupCreateView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setLeftBarButton(groupCreateView?.backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.title = "그룹 생성"
        
        self.addKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeKeyboardNotifications()
        if isMovingFromParent {
            viewModel?.actions.finishScene?()
        }
    }
}

// MARK: bind viewModel
private extension GroupCreateViewController {
    func bind() {
        guard let viewModel,
              let groupCreateView else { return }
        
        groupCreateView
            .infoView
            .groupImageButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.presentPhotoPicker()
            })
            .disposed(by: bag)
        
        let input = GroupCreateViewModel.Input(
            titleChanged: groupCreateView.infoView.groupNameField.rx.text.skip(1).asObservable(),
            noticeChanged: groupCreateView.infoView.groupNoticeTextView.rx.text.skip(1).asObservable(),
            titleImageChanged: titleImageChanged.asObservable(),
            tagAdded: tagAdded.asObservable(),
            tagRemovedAt: tagRemovedAt.asObservable(),
            maxMemberChanged: groupCreateView.limitView.didChangedLimitValue.asObservable(),
            saveBtnTapped: groupCreateView.createButtonView.wideButton.rx.tap.asObservable(),
            backBtnTapped: groupCreateView.backButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output
            .titleFilled
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                groupCreateView.infoView.groupNameField.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)
        
        output
            .noticeFilled
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                groupCreateView.infoView.groupNoticeTextView.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)
        
        output
            .imageFilled
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                groupCreateView.infoView.groupNoticeTextView.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)
        
        output
            .maxCountFilled
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                groupCreateView.limitView.limitField.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)
        
        output
            .isCreateButtonEnabled
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, enabled in
                groupCreateView.createButtonView.wideButton.isEnabled = enabled
                groupCreateView.createButtonView.wideButton.alpha = enabled ? 1.0 : 0.5
            })
            .disposed(by: bag)
        
        viewModel.checkTagValidation()
        
        output
            .tagCountValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                groupCreateView.tagView.tagCountCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .tagDuplicateValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                groupCreateView.tagView.duplicateValidateCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .didChangedTitleImage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, data in
                guard let data = data else {
                    groupCreateView.infoView.groupImageView.image = UIImage(named: "GroupCreateDefaultImage")
                    return
                }
                groupCreateView.infoView.groupImageView.image = UIImage(data: data)
            })
            .disposed(by: bag)
        
        output
            .insertTagAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.insertTagAt(index: index)
            })
            .disposed(by: bag)
        
        output
            .remvoeTagAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.removeTagAt(index: index)
            })
            .disposed(by: bag)
    }
}

// MARK: - configure
private extension GroupCreateViewController {
    func configureView() {
        groupCreateView?.tagView.tagCollectionView.dataSource = self
        groupCreateView?.tagView.tagCollectionView.delegate = self
        
        addKeyboardSizeView()
        hideKeyboardWithTap()
    }
}

// MARK: Actions
private extension GroupCreateViewController {
    func insertTagAt(index: Int) {
        guard let groupCreateView,
              let viewModel else { return }
        let maxTagCnt = viewModel.maxTagCnt
        
        if viewModel.tagList.count == maxTagCnt {
            groupCreateView
                .tagView
                .tagCollectionView
                .performBatchUpdates({
                    groupCreateView.tagView
                        .tagCollectionView
                        .reloadItems(at: [IndexPath(item: maxTagCnt-1, section: 0)])
                }, completion: { _ in
                    UIView.performWithoutAnimation {
                        groupCreateView.tagView
                            .tagCollectionView
                            .reloadSections(IndexSet(integer: 0))
                    }
                })
        } else {
            groupCreateView
                .tagView
                .tagCollectionView
                .performBatchUpdates({
                    groupCreateView.tagView
                        .tagCollectionView
                        .insertItems(at: [IndexPath(item: index, section: 0)])
                }, completion: { _ in
                    UIView.performWithoutAnimation {
                        groupCreateView.tagView
                            .tagCollectionView
                            .reloadSections(IndexSet(integer: 0))
                    }
                })
        }
    }
    
    func removeTagAt(index: Int) {
        guard let groupCreateView,
              let viewModel else { return }
        let maxTagCnt = viewModel.maxTagCnt
        
        if viewModel.tagList.count == maxTagCnt - 1 {
            groupCreateView
                .tagView
                .tagCollectionView
                .performBatchUpdates({
                    groupCreateView.tagView
                        .tagCollectionView
                        .deleteItems(at: [IndexPath(item: index, section: 0)])
                    groupCreateView.tagView
                        .tagCollectionView
                        .insertItems(at: [IndexPath(item: maxTagCnt-1, section: 0)])
                }, completion: { _ in
                    UIView.performWithoutAnimation {
                        groupCreateView.tagView
                            .tagCollectionView
                            .reloadSections(IndexSet(integer: 0))
                    }
                })
        } else {
            groupCreateView
                .tagView
                .tagCollectionView
                .performBatchUpdates({
                    groupCreateView.tagView
                        .tagCollectionView
                        .deleteItems(at: [IndexPath(item: index, section: 0)])
                }, completion: { _ in
                    UIView.performWithoutAnimation {
                        groupCreateView.tagView
                            .tagCollectionView
                            .reloadSections(IndexSet(integer: 0))
                    }
                })
        }

    }
    
    func presentPhotoPicker() {
        var phPickerConfiguration = PHPickerConfiguration()
        phPickerConfiguration.selectionLimit = 1
        phPickerConfiguration.filter = .images
        phPickerConfiguration.preferredAssetRepresentationMode = .current
        
        let phPicker = PHPickerViewController(configuration: phPickerConfiguration)
        phPicker.delegate = self
        self.present(phPicker, animated: true)
    }
}

// MARK: Keyboard
private extension GroupCreateViewController {
    func hideKeyboardWithTap() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func addKeyboardSizeView() {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.snp.makeConstraints {
            $0.height.equalTo(0)
        }
        groupCreateView?.keyboardHeightConstraint = view.constraints.first(where: { $0.firstAttribute == .height })
        
        groupCreateView?.contentStackView.addArrangedSubview(view)
    }
    
    func addKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 노티피케이션을 제거하는 메서드
    func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let groupCreateView,
              let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        guard let firstResponder = self.view.firstResponder else { return }
        
        // 키보드에 가려진 후의 frame
        let container = CGRect(
            x: groupCreateView.scrollView.contentOffset.x,
            y: groupCreateView.scrollView.contentOffset.y,
            width: self.view.frame.width,
            height: self.view.frame.height - keyboardFrame.height
        )
        
        let globalFrame = firstResponder.convert(firstResponder.frame, to: groupCreateView.scrollView)
        
        if !CGRectIntersectsRect(container, globalFrame) { // 만약 안보이면? 이동시켜주기!
            groupCreateView.scrollView.setContentOffset(
                CGPoint(x: groupCreateView.scrollView.contentOffset.x, y: groupCreateView.scrollView.contentOffset.y + keyboardFrame.height),
                animated: true
            )
        }
        
        groupCreateView.keyboardHeightConstraint?.constant = keyboardFrame.height
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        groupCreateView?.keyboardHeightConstraint?.constant = 0
    }
}

extension GroupCreateViewController: PHPickerViewControllerDelegate { //PHPicker 델리게이트
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (item, error) in
            guard let fileName = results.first?.itemProvider.suggestedName,
                  var image = item as? UIImage  else { return }
            
            image = UIImage.resizeImage(image: image, targetWidth: 500)
            if let data = image.jpegData(compressionQuality: 1) {
                self?.titleImageChanged.accept(ImageFile(filename: fileName, data: data, type: "jpeg"))
            }
        }
    }
}

extension GroupCreateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
                self?.tagRemovedAt.accept(indexPath.item)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.item == (viewModel?.tagList.count ?? 0) {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return false }
            self.shouldPresentTagVC(cell: cell)
        }
        return false
    }
}

private extension GroupCreateViewController {
    func shouldPresentTagVC(cell collectionViewCell: UICollectionViewCell) {
        guard let groupCreateView,
              let viewModel else { return }
        
        let vc = GroupTagInputViewController(isInfoViewing: viewModel.initialTagPopedOver)
        viewModel.initialTagPopedOver = false
        
        vc.tagAddclosure = { [weak self] tag in
            self?.tagAdded.accept(tag)
        }
        vc.keyboardAppearWithHeight = { [weak self] keyboardHeight in
            guard let self else { return }
            let container = CGRect(
                x: groupCreateView.scrollView.contentOffset.x,
                y: groupCreateView.scrollView.contentOffset.y,
                width: groupCreateView.scrollView.frame.size.width,
                height: groupCreateView.scrollView.frame.size.height - keyboardHeight
            )
            let realCenter = groupCreateView.tagView.tagCollectionView.convert(collectionViewCell.center, to: self.view)
            
            let currentYRange = groupCreateView.scrollView.contentOffset.y...groupCreateView.scrollView.contentOffset.y + self.view.frame.height - keyboardHeight
            if !currentYRange.contains(realCenter.y) {
                groupCreateView.scrollView.setContentOffset(
                    CGPoint(
                        x: groupCreateView.scrollView.contentOffset.x,
                        y: groupCreateView.scrollView.contentOffset.y + keyboardHeight
                    ),
                    animated: true
                )
            }
            
            groupCreateView.keyboardHeightConstraint?.constant = keyboardHeight
        }
        
        vc.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = groupCreateView.scrollView
        let globalFrame = collectionViewCell.convert(collectionViewCell.bounds, to: groupCreateView.scrollView)
        popover.sourceRect = CGRect(x: globalFrame.midX, y: globalFrame.minY, width: 0, height: 0)
        popover.permittedArrowDirections = [.down]
        
        self.present(vc, animated: true, completion: nil)
    }
}

extension GroupCreateViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension GroupCreateViewController: UIGestureRecognizerDelegate {}

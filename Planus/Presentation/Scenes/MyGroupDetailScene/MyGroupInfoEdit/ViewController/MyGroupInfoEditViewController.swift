//
//  MyGroupInfoEditViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class MyGroupInfoEditViewController: UIViewController {
    
    var bag = DisposeBag()
    
    var viewModel: MyGroupInfoEditViewModel?
    private var myGroupInfoEditView: MyGroupInfoEditView?
    
    var tagAdded = PublishRelay<String>()
    var tagRemovedAt = PublishRelay<Int>()
    var removeBtnTapped = PublishRelay<Void>()
    
    var titleImageChanged = PublishRelay<ImageFile?>()
    
    var keyboardHeightConstraint: NSLayoutConstraint?
    
    convenience init(viewModel: MyGroupInfoEditViewModel) {
        self.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let view = MyGroupInfoEditView(frame: self.view.frame)
        self.view = view
        self.myGroupInfoEditView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let myGroupInfoEditView else { return }
        
        self.navigationItem.setLeftBarButton(myGroupInfoEditView.backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.setRightBarButton(myGroupInfoEditView.saveButton, animated: false)
        self.navigationItem.rightBarButtonItem?.tintColor = .black
        self.navigationItem.title = "그룹 편집"
        
        addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardNotifications()
    }
}

// MARK: - confiugre VC
private extension MyGroupInfoEditViewController {
    func configureVC() {
        addKeyboardSizeView()
        hideKeyboardWithTap()
        
        myGroupInfoEditView?.tagView.tagCollectionView.dataSource = self
        myGroupInfoEditView?.tagView.tagCollectionView.delegate = self

        myGroupInfoEditView?.infoView.groupImageButton.addTarget(self, action: #selector(imageBtnTapped), for: .touchUpInside)
    }
}

// MARK: - bind
private extension MyGroupInfoEditViewController {
    func bind() {
        guard let viewModel,
                let myGroupInfoEditView else { return }
        
        myGroupInfoEditView.infoView.groupNameField.text = viewModel.title
        myGroupInfoEditView.limitView.limitField.text = "\((try? viewModel.maxMember.value()) ?? 0)"
        
        myGroupInfoEditView
            .removeButtonView
            .wideButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.showPopUp(title: "그룹 삭제하기", message: "삭제된 그룹은 추후 복구할 수 없습니다.", alertAttrs: [
                    CustomAlertAttr(title: "취소", actionHandler: {}, type: .normal),
                    CustomAlertAttr(title: "삭제", actionHandler: { [weak self] in self?.removeBtnTapped.accept(()) }, type: .warning)]
                )
            })
            .disposed(by: bag)
        
        let input = MyGroupInfoEditViewModel.Input(
            titleImageChanged: titleImageChanged.asObservable(),
            tagAdded: tagAdded.asObservable(),
            tagRemovedAt: tagRemovedAt.asObservable(),
            maxMemberChanged: myGroupInfoEditView.limitView.didChangedLimitValue.asObservable(),
            saveBtnTapped: myGroupInfoEditView.saveButton.rx.tap.asObservable(),
            removeBtnTapped: removeBtnTapped.asObservable(),
            backBtnTapped: myGroupInfoEditView.backButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .maxCountFilled
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                myGroupInfoEditView.limitView.limitField.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)
        
        output
            .isUpdateButtonEnabled
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: myGroupInfoEditView.saveButton.rx.isEnabled)
            .disposed(by: bag)
        
        output
            .tagCountValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                myGroupInfoEditView.tagView.tagCountCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .tagDuplicateValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                myGroupInfoEditView.tagView.duplicateValidateCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .didChangedTitleImage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, data in
                if let data {
                    myGroupInfoEditView.infoView.groupImageView.image = UIImage(data: data)
                } else {
                    myGroupInfoEditView.infoView.groupImageView.image = UIImage(named: "GroupCreateDefaultImage")
                }
            })
            .disposed(by: bag)
        
        output
            .insertTagAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.insertTag(at: index)
            })
            .disposed(by: bag)
        
        output
            .removeTagAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc.removeTag(at: index)
            })
            .disposed(by: bag)
        
        output
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.view.endEditing(true)
                vc.showToast(message: message.text, type: Message.toToastType(state: message.state))
            })
            .disposed(by: bag)
        
    }
}

// MARK: - Tag Actions
private extension MyGroupInfoEditViewController {
    func insertTag(at index: Int) {
        guard let myGroupInfoEditView,
              let viewModel else { return }
        let maxTagCnt = viewModel.maxTagCnt
        
        if viewModel.tagList.count == maxTagCnt {
            myGroupInfoEditView
                .tagView
                .tagCollectionView
                .performBatchUpdates({
                    myGroupInfoEditView.tagView
                        .tagCollectionView
                        .reloadItems(at: [IndexPath(item: maxTagCnt-1, section: 0)])
                }, completion: { _ in
                    UIView.performWithoutAnimation {
                        myGroupInfoEditView.tagView
                            .tagCollectionView
                            .reloadSections(IndexSet(integer: 0))
                    }
                })
        } else {
            myGroupInfoEditView
                .tagView
                .tagCollectionView
                .performBatchUpdates({
                    myGroupInfoEditView.tagView
                        .tagCollectionView
                        .insertItems(at: [IndexPath(item: index, section: 0)])
                }, completion: { _ in
                    UIView.performWithoutAnimation {
                        myGroupInfoEditView.tagView
                            .tagCollectionView
                            .reloadSections(IndexSet(integer: 0))
                    }
                })
        }
    }
    
    func removeTag(at index: Int) {
        guard let myGroupInfoEditView,
              let viewModel else { return }
        let maxTagCnt = viewModel.maxTagCnt
        
        if viewModel.tagList.count == maxTagCnt - 1 {
            myGroupInfoEditView
                .tagView
                .tagCollectionView
                .performBatchUpdates({
                    myGroupInfoEditView.tagView
                        .tagCollectionView
                        .deleteItems(at: [IndexPath(item: index, section: 0)])
                    myGroupInfoEditView.tagView
                        .tagCollectionView
                        .insertItems(at: [IndexPath(item: maxTagCnt-1, section: 0)])
                }, completion: { _ in
                    UIView.performWithoutAnimation {
                        myGroupInfoEditView.tagView
                            .tagCollectionView
                            .reloadSections(IndexSet(integer: 0))
                    }
                })
        } else {
            myGroupInfoEditView
                .tagView
                .tagCollectionView
                .performBatchUpdates({
                    myGroupInfoEditView.tagView
                        .tagCollectionView
                        .deleteItems(at: [IndexPath(item: index, section: 0)])
                }, completion: { _ in
                    UIView.performWithoutAnimation {
                        myGroupInfoEditView.tagView
                            .tagCollectionView
                            .reloadSections(IndexSet(integer: 0))
                    }
                })
        }

    }
}

// MARK: - Actions
private extension MyGroupInfoEditViewController {
    @objc 
    func imageBtnTapped(_ sender: UIButton) {
        presentPhotoPicker()
    }
}

extension MyGroupInfoEditViewController: PHPickerViewControllerDelegate {
    func presentPhotoPicker() {
        var phPickerConfiguration = PHPickerConfiguration()
        phPickerConfiguration.selectionLimit = 1
        phPickerConfiguration.filter = .images
        phPickerConfiguration.preferredAssetRepresentationMode = .current
        
        let phPicker = PHPickerViewController(configuration: phPickerConfiguration)
        phPicker.delegate = self
        self.present(phPicker, animated: true)
    }
    
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

extension MyGroupInfoEditViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
            self.shouldPresentTestVC(cell: cell)
        }
        return false
    }
}

// MARK: - Keyboard
extension MyGroupInfoEditViewController {
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
        self.keyboardHeightConstraint = view.constraints.first(where: { $0.firstAttribute == .height })
        myGroupInfoEditView?.contentStackView.addArrangedSubview(view)
    }
    
    func addKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc 
    func keyboardWillShow(_ sender: Notification) {
        guard let myGroupInfoEditView,
              let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let firstResponder = self.view.firstResponder else {
            return
        }

        // 키보드에 가려진 후의 frame
        let container = CGRect(
            x: myGroupInfoEditView.scrollView.contentOffset.x,
            y: myGroupInfoEditView.scrollView.contentOffset.y,
            width: self.view.frame.width,
            height: self.view.frame.height - keyboardFrame.height
        )
                
        let globalFrame = firstResponder.convert(firstResponder.frame, to: myGroupInfoEditView.scrollView)

        if !CGRectIntersectsRect(container, globalFrame) { // 만약 안보이면 이동시켜주기
            myGroupInfoEditView.scrollView.setContentOffset(
                CGPoint(
                    x: myGroupInfoEditView.scrollView.contentOffset.x,
                    y: myGroupInfoEditView.scrollView.contentOffset.y + keyboardFrame.height
                ),
                animated: true
            )
        }
        
        self.keyboardHeightConstraint?.constant = keyboardFrame.height
    }
    
    @objc 
    func keyboardWillHide(_ sender: Notification) {
        self.keyboardHeightConstraint?.constant = 0
    }
    
}

extension MyGroupInfoEditViewController {
    func shouldPresentTestVC(cell collectionViewCell: UICollectionViewCell) {
        guard let myGroupInfoEditView else { return }
        let vc = GroupTagInputViewController(nibName: nil, bundle: nil)
        vc.tagAddclosure = { [weak self] tag in
            self?.tagAdded.accept(tag)
        }
        
        vc.keyboardAppearWithHeight = { [weak self] keyboardHeight in
            guard let self else { return }
            let container = CGRect(
                x: myGroupInfoEditView.scrollView.contentOffset.x,
                y: myGroupInfoEditView.scrollView.contentOffset.y,
                width: myGroupInfoEditView.scrollView.frame.size.width,
                height: myGroupInfoEditView.scrollView.frame.size.height - keyboardHeight
            )
            let realCenter = myGroupInfoEditView.tagView.tagCollectionView.convert(collectionViewCell.center, to: self.view)
   
            let currentYRange = myGroupInfoEditView.scrollView.contentOffset.y...myGroupInfoEditView.scrollView.contentOffset.y + self.view.frame.height - keyboardHeight
            if !currentYRange.contains(realCenter.y) {
                myGroupInfoEditView.scrollView.setContentOffset(
                    CGPoint(
                        x: myGroupInfoEditView.scrollView.contentOffset.x,
                        y: myGroupInfoEditView.scrollView.contentOffset.y + keyboardHeight
                    ),
                    animated: true
                )
            }
        }
        
        vc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 60)
        vc.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = myGroupInfoEditView.scrollView
        let globalFrame = collectionViewCell.convert(collectionViewCell.bounds, to: myGroupInfoEditView.scrollView)
        popover.sourceRect = CGRect(x: globalFrame.midX, y: globalFrame.minY, width: 0, height: 0)
        popover.permittedArrowDirections = [.down]
        
        self.present(vc, animated: true, completion: nil)
    }
}

extension MyGroupInfoEditViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension MyGroupInfoEditViewController: UIGestureRecognizerDelegate {}

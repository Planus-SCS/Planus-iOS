//
//  MyGroupInfoEditViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/05/15.
//

import UIKit
import RxSwift
import PhotosUI

class MyGroupInfoEditViewController: UIViewController {
    
    var bag = DisposeBag()
    var viewModel: MyGroupInfoEditViewModel?
    
    var tagAdded = PublishSubject<String>()
    var tagRemovedAt = PublishSubject<Int>()
    var removeBtnTapped = PublishSubject<Void>()
    
    var titleImageChanged = PublishSubject<ImageFile?>()
    
    var scrollView = UIScrollView(frame: .zero)
    var keyboardHeightConstraint: NSLayoutConstraint?
    
    var contentStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()
    
    var infoView: GroupEditInfoView = .init(frame: .zero)
    var tagView: GroupCreateTagView = .init(frame: .zero)
    var limitView: GroupCreateLimitView = .init(frame: .zero)
    var createButtonView: WideButtonView = {
        let view = WideButtonView.init(frame: .zero)
        view.wideButton.backgroundColor = .systemPink
        view.wideButton.setTitle("그룹 삭제하기", for: .normal)
        return view
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let image = UIImage(named: "back")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backBtnAction))
        item.tintColor = .black
        return item
    }()
    
    lazy var saveButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveBtnTapped))
        item.tintColor = UIColor(hex: 0x6495F4)
        return item
    }()
    
    @objc func saveBtnTapped(_ sender: UIBarButtonItem) {}
    
    @objc func backBtnAction() {
        navigationController?.popViewController(animated: true)
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureLayout()
        addKeyboardSizeView()
        hideKeyboardWithTap()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setLeftBarButton(backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.setRightBarButton(saveButton, animated: false)
        self.navigationItem.title = "그룹 편집"
        addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardNotifications()
    }
    
    func bind() {
        guard let viewModel else { return }
        
        infoView.groupNameField.text = viewModel.title
        limitView.limitField.text = "\((try? viewModel.maxMember.value()) ?? 0)"
        
        createButtonView
            .wideButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.showPopUp(title: "그룹 삭제하기", message: "삭제된 그룹은 추후 복구할 수 없습니다.", alertAttrs: [
                    CustomAlertAttr(title: "취소", actionHandler: {}, type: .normal),
                    CustomAlertAttr(title: "삭제", actionHandler: { [weak self] in self?.removeBtnTapped.onNext(()) }, type: .warning)]
                )
            })
            .disposed(by: bag)
        
        let input = MyGroupInfoEditViewModel.Input(
            titleImageChanged: titleImageChanged.asObservable(),
            tagAdded: tagAdded.asObservable(),
            tagRemovedAt: tagRemovedAt.asObservable(),
            maxMemberChanged: limitView.didChangedLimitValue.asObservable(),
            saveBtnTapped: saveButton.rx.tap.asObservable(),
            removeBtnTapped: removeBtnTapped.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .maxCountFilled
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                vc.limitView.limitField.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)
        
        output
            .isUpdateButtonEnabled
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, enabled in
                vc.createButtonView.wideButton.isEnabled = enabled
                vc.createButtonView.wideButton.alpha = enabled ? 1.0 : 0.4
            })
            .disposed(by: bag)
        
        output
            .tagCountValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                vc.tagView.tagCountCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .tagDuplicateValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                vc.tagView.duplicateValidateCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .didChangedTitleImage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, data in
                guard let data = data else {
                    vc.infoView.groupImageView.image = UIImage(named: "GroupCreateDefaultImage")
                    return
                }
                vc.infoView.groupImageView.image = UIImage(data: data)
            })
            .disposed(by: bag)
        
        output
            .infoUpdateCompleted
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
        
        output
            .insertTagAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc
                    .tagView
                    .tagCollectionView
                    .performBatchUpdates({
                        vc
                            .tagView
                            .tagCollectionView
                            .insertItems(at: [IndexPath(item: index, section: 0)])
                    }, completion: { _ in
                        UIView.performWithoutAnimation {
                            vc
                                .tagView
                                .tagCollectionView
                                .reloadSections(IndexSet(0...0))
                        }
                    })
            })
            .disposed(by: bag)
        
        output
            .removeTagAt
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, index in
                vc
                    .tagView
                    .tagCollectionView
                    .performBatchUpdates({
                        vc
                            .tagView
                            .tagCollectionView
                            .deleteItems(at: [IndexPath(item: index, section: 0)])
                    }, completion: { _ in
                        UIView.performWithoutAnimation {
                            vc
                                .tagView
                                .tagCollectionView
                                .reloadSections(IndexSet(0...0))
                        }
                    })
                
                
            })
            .disposed(by: bag)
        
        output
            .groupDeleted
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: bag)
        
        output
            .showMessage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, message in
                vc.showToast(message: message.text, type: Message.toToastType(state: message.state))
            })
            .disposed(by: bag)
        
    }
    
    func configureView() {
        tagView.tagCollectionView.dataSource = self
        tagView.tagCollectionView.delegate = self
        
        self.view.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(infoView)
        contentStackView.addArrangedSubview(tagView)
        contentStackView.addArrangedSubview(limitView)
        contentStackView.addArrangedSubview(createButtonView)
        
        infoView.groupImageButton.addTarget(self, action: #selector(imageBtnTapped), for: .touchUpInside)
    }
    
    @objc func imageBtnTapped(_ sender: UIButton) {
        presentPhotoPicker()
    }
    
    func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        contentStackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
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

extension MyGroupInfoEditViewController: PHPickerViewControllerDelegate { //PHPicker 델리게이트
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (item, error) in
            guard let fileName = results.first?.itemProvider.suggestedName,
                  var image = item as? UIImage  else { return }
            
            image = UIImage.resizeImage(image: image, targetWidth: 500)
            if let data = image.pngData() {
                self?.titleImageChanged.onNext(ImageFile(filename: fileName, data: data, type: "png"))
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
                self?.tagRemovedAt.onNext(indexPath.item)
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
        
        self.contentStackView.addArrangedSubview(view)
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
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        guard let firstResponder = self.view.firstResponder else { return }

        // 키보드에 가려진 후의 frame
        let container = CGRect(
            x: scrollView.contentOffset.x,
            y: scrollView.contentOffset.y,
            width: self.view.frame.width,
            height: self.view.frame.height - keyboardFrame.height
        )
                
        let globalFrame = firstResponder.convert(firstResponder.frame, to: scrollView)

        if !CGRectIntersectsRect(container, globalFrame) { // 만약 안보이면? 이동시켜주기!
            scrollView.setContentOffset(
                CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + keyboardFrame.height),
                animated: true
            )
        }
        
        self.keyboardHeightConstraint?.constant = keyboardFrame.height
        
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        self.keyboardHeightConstraint?.constant = 0
    }
    
}

extension MyGroupInfoEditViewController {
    func shouldPresentTestVC(cell collectionViewCell: UICollectionViewCell) {
        let vc = GroupTagInputViewController(nibName: nil, bundle: nil)
        vc.tagAddclosure = { [weak self] tag in
            self?.tagAdded.onNext(tag)
        }
        
        vc.keyboardAppearWithHeight = { [weak self] keyboardHeight in
            guard let self else { return }
            let container = CGRect(
                x: self.scrollView.contentOffset.x,
                y: self.scrollView.contentOffset.y,
                width: self.scrollView.frame.size.width,
                height: self.scrollView.frame.size.height - keyboardHeight
            )
            let realCenter = self.tagView.tagCollectionView.convert(collectionViewCell.center, to: self.view)
   
            let currentYRange = self.scrollView.contentOffset.y...self.scrollView.contentOffset.y + self.view.frame.height - keyboardHeight
            if !currentYRange.contains(realCenter.y) {
                self.scrollView.setContentOffset(
                    CGPoint(x: self.scrollView.contentOffset.x, y: self.scrollView.contentOffset.y + keyboardHeight),
                    animated: true
                )
            }
        }
        
        vc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 60)
        vc.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceItem = collectionViewCell
        
        self.present(vc, animated: true, completion: nil)
    }
}

extension MyGroupInfoEditViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension MyGroupInfoEditViewController: UIGestureRecognizerDelegate {}

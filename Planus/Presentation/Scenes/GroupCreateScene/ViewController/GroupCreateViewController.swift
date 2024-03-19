//
//  GroupCreateViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/30.
//

import UIKit
import RxSwift
import PhotosUI

class GroupCreateViewController: UIViewController {

    var bag = DisposeBag()
    var viewModel: GroupCreateViewModel?
    
    var tagAdded = PublishSubject<String>()
    var tagRemovedAt = PublishSubject<Int>()
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
        viewModel?.actions.pop?()
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
        addKeyboardSizeView()
        hideKeyboardWithTap()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setLeftBarButton(backButton, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.title = "그룹 생성"
        
        self.addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel?.actions.finishScene?()
    }
    
    func bind() {
        guard let viewModel else { return }
        
        let input = GroupCreateViewModel.Input(
            titleChanged: infoView.groupNameField.rx.text.skip(1).asObservable(),
            noticeChanged: infoView.groupNoticeTextView.rx.text.skip(1).asObservable(),
            titleImageChanged: titleImageChanged.asObservable(),
            tagAdded: tagAdded.asObservable(),
            tagRemovedAt: tagRemovedAt.asObservable(),
            maxMemberChanged: limitView.didChangedLimitValue.asObservable(),
            saveBtnTapped: createButtonView.wideButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output
            .titleFilled
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                vc.infoView.groupNameField.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)
        
        output
            .noticeFilled
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                vc.infoView.groupNoticeTextView.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)
        
        output
            .imageFilled
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                vc.infoView.groupNoticeTextView.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)
        
        output
            .maxCountFilled
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, filled in
                vc.limitView.limitField.layer.borderColor
                = filled ? UIColor(hex: 0x6F81A9).cgColor : UIColor(hex: 0xEA4335).cgColor
            })
            .disposed(by: bag)

        output
            .isCreateButtonEnabled
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, enabled in
                vc.createButtonView.wideButton.isEnabled = enabled
                vc.createButtonView.wideButton.alpha = enabled ? 1.0 : 0.5
            })
            .disposed(by: bag)
        
        viewModel.checkTagValidation()
        
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
            .remvoeTagAt
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
    }
    
    func configureView() {
        tagView.tagCollectionView.dataSource = self
        tagView.tagCollectionView.delegate = self
        
        createButtonView.wideButton.setTitle("그룹 생성하기", for: .normal)

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

extension GroupCreateViewController {
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

extension GroupCreateViewController: PHPickerViewControllerDelegate { //PHPicker 델리게이트
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (item, error) in
            guard let fileName = results.first?.itemProvider.suggestedName,
                  var image = item as? UIImage  else { return }
            
            image = UIImage.resizeImage(image: image, targetWidth: 500)
            if let data = image.jpegData(compressionQuality: 1) {
                self?.titleImageChanged.onNext(ImageFile(filename: fileName, data: data, type: "jpeg"))
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

extension GroupCreateViewController {
    func shouldPresentTestVC(cell collectionViewCell: UICollectionViewCell) {
        guard let viewModel else { return }
        
        let vc = GroupTagInputViewController(isInfoViewing: viewModel.initialTagPopedOver)
        viewModel.initialTagPopedOver = false
        
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
            
            self.keyboardHeightConstraint?.constant = keyboardHeight
        }
        
        vc.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.scrollView
        let globalFrame = collectionViewCell.convert(collectionViewCell.bounds, to: self.scrollView)
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

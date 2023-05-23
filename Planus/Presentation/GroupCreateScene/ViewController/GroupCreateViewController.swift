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
        navigationController?.popViewController(animated: true)
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
    
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setLeftBarButton(backButton, animated: false)
        self.navigationItem.title = "그룹 생성"
    }
    
    func bind() {
        guard let viewModel else { return }

        let noticeChanged = infoView.groupNoticeTextView.rx.text.asObservable().map { [weak self] text -> String? in
            guard let self else { return nil }
            return self.infoView.isDescEditing ? text : nil
        }
        
        tagAdded.subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
        
        let input = GroupCreateViewModel.Input(
            titleChanged: infoView.groupNameField.rx.text.asObservable(),
            noticeChanged: noticeChanged,
            titleImageChanged: titleImageChanged.asObservable(),
            tagAdded: tagAdded.asObservable(),
            tagRemovedAt: tagRemovedAt.asObservable(),
            maxMemberChanged: limitView.limitField.rx.text.asObservable(),
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
        
        output
            .tagCountValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                vc.tagView.tagCountCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .tagCharCountValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                vc.tagView.stringCountCheckView.isValid(validation)
            })
            .disposed(by: bag)
        
        output
            .tagSpecialCharValidState
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, validation in
                vc.tagView.charValidateCheckView.isValid(validation)
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
            .showCreateLoadPage
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, groupInfo in
                let api = NetworkManager()
                let keyChain = KeyChainManager()
                let tokenRepo = DefaultTokenRepository(apiProvider: api, keyChainManager: keyChain)
                let getToken = DefaultGetTokenUseCase(tokenRepository: tokenRepo)
                let refToken = DefaultRefreshTokenUseCase(tokenRepository: tokenRepo)
                let groupCreate = DefaultGroupCreateUseCase.shared
                let viewModel = GroupCreateLoadViewModel(getTokenUseCase: getToken, refreshTokenUseCase: refToken, groupCreateUseCase: groupCreate)
                viewModel.setGroupCreate(groupCreate: groupInfo.0, image: groupInfo.1)
                let viewController = GroupCreateLoadViewController(viewModel: viewModel)
                vc.navigationController?.pushViewController(viewController, animated: true)
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

extension GroupCreateViewController: PHPickerViewControllerDelegate { //PHPicker 델리게이트
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
            guard let fileName = results.first?.itemProvider.suggestedName else { return }
            if let data = (image as? UIImage)?.pngData() {
                self?.titleImageChanged.onNext(ImageFile(filename: fileName, data: data, type: "png"))
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
        let vc = GroupTagInputViewController(nibName: nil, bundle: nil)
        vc.tagAddclosure = { [weak self] tag in
            self?.tagAdded.onNext(tag)            
        }
        
        vc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 60)
        vc.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceItem = collectionViewCell
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func shouldRemoveTagAt(index: IndexPath) {
        self.tagRemovedAt.onNext(index.item)
    }
    
    
}

extension GroupCreateViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
